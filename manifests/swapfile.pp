class swapfile (
  String $swapfile     = '/swapfile',
  String $swapfilesize = '4096' # Размер в МБ
) {

  # Вычисляем размер в блоках по 1М для утилиты stat (4096 МБ = 4294967296 байт)
  $size_in_bytes = inline_template('<%= @swapfilesize.to_i * 1024 * 1024 %>')

  exec { 'Disable non-compliant swap':
    path    => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
    command => "swapoff ${swapfile} || swapoff -a",
    # Запускать отключение если файл существует, но его размер НЕ совпадает с целевым
    onlyif  => "test -f ${swapfile} && test \"\$(stat -c %s ${swapfile})\" -ne ${size_in_bytes}",
    before  => Exec['Purge old swapfile if size incorrect'],
  }

  exec { 'Purge old swapfile if size incorrect':
    path    => ['/bin', '/usr/bin'],
    command => "rm -f ${swapfile}",
    # Удаляем если размер файла на диске не равен целевому
    onlyif  => "test -f ${swapfile} && test \"\$(stat -c %s ${swapfile})\" -ne ${size_in_bytes}",
    before  => Exec['Create swap file'],
  }

  # Создаем файл подкачки
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

  # Очистка fstab от старых записей
  exec { 'Clean old swap entries from fstab':
    path    => ['/bin', '/usr/bin'],
    command => "sed -i '/swap/ { /^${swapfile}\\s/!d }' /etc/fstab",
    onlyif  => "grep 'swap' /etc/fstab | grep -vE '^${swapfile}\\s'",
    before  => File_line['Add swap in fstab'],
  }

  # Добавляем запись в fstab
  file_line { 'Add swap in fstab':
    ensure  => 'present',
    path    => '/etc/fstab',
    line    => "${swapfile} none swap sw 0 0",
    match   => "^${swapfile}\\s",
    require => Exec['Attach swap file'],
  }
}
