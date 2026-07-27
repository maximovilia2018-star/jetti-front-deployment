# modules/profile/manifests/timezone_ua.pp
class profile::timezone_ua {

  # Принудительно выставляем совместимую таймзону для старого софта
  file { '/etc/localtime':
    ensure => 'link',
    target => '/usr/share/zoneinfo/Europe/Kiev',
    force  => true, # Обязательно, чтобы перезаписать существующую ссылку Ky-iv
  }

  # Обновляем файл /etc/timezone, чтобы системные утилиты не путались
  file { '/etc/timezone':
    ensure  => file,
    content => "Europe/Kiev\n",
  }

}
