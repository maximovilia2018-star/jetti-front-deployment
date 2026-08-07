# modules/profile/manifests/timezone_hu.pp
class profile::timezone_hu {

  file { '/etc/localtime':
    ensure => 'link',
    target => '../usr/share/zoneinfo/Europe/Budapest',
    force  => true,
  }

  # Обновляем файл /etc/timezone, чтобы системные утилиты не путались
  file { '/etc/timezone':
    ensure  => file,
    content => "Europe/Budapest\n",
  }

}
