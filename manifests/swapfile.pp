class swapfile (
  String $swapfile     = '/swapfile',
  String $swapfilesize = '4096' # Целевой размер в МБ
) {

  # Вычисляем целевой размер в байтах
  $target_size_bytes = inline_template('<%= @swapfilesize.to_i * 1024 * 1024 %>')

  # Если файл существует, но его размер отличается от целевого — 
  # мы должны принудительно отключить его, чтобы пересоздать.
  if $facts['memory']['swap']['total_bytes'] != $target_size_bytes {
    
    # Отключаем ВСЕ активные свопы, если общий размер не совпадает с целевым.
    # Это также отключит старые swap-разделы (например, /dev/sda2).
    exec { 'Disable non-compliant swap':
      path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
      command => 'swapoff -a',
      # Запускать только если текущий размер свопа в системе не равен целевому
      onlyif  => "test \"$(swapon -s | wc -l)\" -gt 1",
      before  => Exec['Purge old swapfile if size incorrect'],
    }

    # Удаляем физический файл, если он был не того размера, чтобы dd создал новый
    exec { 'Purge old swapfile if size incorrect':
      path    => ['/bin', '/usr/bin'],
      command => "rm -f ${swapfile}",
      onlyif  => "test -f ${swapfile}",
      before  => Exec['Create swap file'],
    }
  }

  # Создаем файл подкачки (сработает, если файла нет или мы его стерли шагом выше)
  exec { 'Create swap file':
    path    => ['/bin', '/usr/bin'],
    command => "/bin/dd if=/dev/zero of=${swapfile} bs=1M count=${swapfilesize}",
    creates => $swapfile,
  }

  # Выставляем права 0600
  file { "Set permissions for ${swapfile}":
    ensure  => 'present',
    path    => $swapfile,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Exec['Create swap file'],
    before  => Exec['Attach swap file'],
  }

  # Форматируем и включаем
  exec { 'Attach swap file':
    path    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
    command => "/sbin/mkswap ${swapfile} && /sbin/swapon ${swapfile}",
    require => Exec['Create swap file'],
    unless  => "/sbin/swapon -s | /bin/grep -qE '^${swapfile}\\s'",
  }

  # ОЧИСТКА FSTAB: Удаляем все старые упоминания swap-разделов или других файлов;
  # Сначала очищаем fstab от любых строк со словом 'swap', кроме строки с нашим файлом.
  exec { 'Clean old swap entries from fstab':
    path    => ['/bin', '/usr/bin'],
    # Удаляет строки, содержащие 'swap', если они не начинаются с нашего $swapfile
    command => "sed -i '/swap/ { /^${swapfile}\\s/!d }' /etc/fstab",
    # Запускать только если в fstab есть "чужие" записи про swap
    onlyif  => "grep 'swap' /etc/fstab | grep -vE '^${swapfile}\\s'",
    before  => File_line['Add swap in fstab'],
  }

  # Добавляем монтирование нашего $swapfile
  file_line { 'Add swap in fstab':
    ensure  => 'present',
    path    => '/etc/fstab',
    line    => "${swapfile}   none   swap   sw   0 0",
    match   => "^${swapfile}\\s",
    require => Exec['Attach swap file'],
  }
}
