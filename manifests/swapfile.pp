# swapfile.pp - управление файлом подкачки для Ubuntu 20.04/22.04
# 
# Настраивает swap-файл указанного размера. Автоматически корректирует
# размер, если он не соответствует заданному. На POS-терминалах должен
# быть ровно один swap-файл, поэтому все остальные записи в fstab удаляются.
#
# Внимание: класс оптимизирован для стандартных путей без пробелов (например, /swapfile).
class swapfile (
  Stdlib::Absolutepath $swapfile     = '/swapfile',
  Integer[512]         $swapfilesize = 4096,        # Размер в МБ (минимум 512МБ)
) {

  $default_path = ['/bin', '/usr/bin', '/sbin', '/usr/sbin']
  $size_in_bytes = $swapfilesize * 1024 * 1024

  # Экранируем \$, чтобы Puppet не интерпретировал $(...),
  # а командная оболочка выполнила подстановку при выполнении exec.
  $correct_size_check = "test -f ${swapfile} && test \"\$(stat -c %s ${swapfile})\" -eq ${size_in_bytes}"
  $wrong_size_check   = "test -f ${swapfile} && test \"\$(stat -c %s ${swapfile})\" -ne ${size_in_bytes}"
  
  $is_swap_check      = "blkid -o value -s TYPE ${swapfile} 2>/dev/null | grep -qx swap"
  $is_active_check    = "swapon --show=NAME --noheadings | grep -q '^${swapfile}$'"

  # 1. Отключаем старый swap, если его размер изменился
  exec { 'swap_disable':
    command => "swapoff ${swapfile} || swapoff -a",
    onlyif  => "${wrong_size_check} && ${is_active_check}",
    path    => $default_path,
  }

  # 2. Удаляем старый файл, если размер не соответствует
  exec { 'swap_remove':
    command => "rm -f ${swapfile}",
    onlyif  => $wrong_size_check,
    path    => $default_path,
  }

  # 3. Создаем новый swap-файл (fallocate с fallback на dd)
  exec { 'swap_create':
    command => "fallocate -l ${swapfilesize}M ${swapfile} || dd if=/dev/zero of=${swapfile} bs=1M count=${swapfilesize}",
    unless  => $correct_size_check,
    timeout => 1800,
    path    => $default_path,
  }

  # 4. Выставляем права (0600) — классический паттерн Puppet в строгом стиле
  file { $swapfile:
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
  }

  # 5. Форматируем swap-файл (только если он еще не swap)
  exec { 'swap_mkswap':
    command => "mkswap ${swapfile}",
    unless  => $is_swap_check,
    path    => $default_path,
  }

  # 6. Включаем swap (если он еще не активен)
  exec { 'swap_enable':
    command => "swapon ${swapfile}",
    unless  => $is_active_check,
    path    => $default_path,
  }

  # 7. Очистка fstab: удаляем любые раскомментированные строки swap, 
  # которые НЕ принадлежат нашему целевому файлу. Комментарии не трогаем.
  exec { 'swap_clean_fstab':
    command => "sed -i '/^[[:space:]]*#/! { /[[:space:]]swap[[:space:]]/ { /^${swapfile}[[:space:]]/!d } }' /etc/fstab",
    onlyif  => "grep -Ev '^[[:space:]]*(#|${swapfile}[[:space:]])' /etc/fstab | grep -q '[[:space:]]swap[[:space:]]'",
    path    => $default_path,
  }

  # 8. Добавляем/актуализируем запись в fstab
  file_line { 'swap_fstab':
    ensure => present,
    path   => '/etc/fstab',
    line   => "${swapfile}    none    swap    sw    0 0",
    match  => "^${swapfile}[[:space:]]",
  }

  # Линейная цепочка выполнения
  Exec['swap_disable']
    -> Exec['swap_remove']
    -> Exec['swap_create']
    -> File[$swapfile]
    -> Exec['swap_mkswap']
    -> Exec['swap_enable']
    -> Exec['swap_clean_fstab']
    -> File_line['swap_fstab']
}
