# modules/profile/manifests/timezone_ae.pp
class profile::timezone_ae {

  file { '/etc/localtime':
    ensure => 'link',
    target => '../usr/share/zoneinfo/Asia/Dubai',
    force  => true,
  }

  # Обновляем файл /etc/timezone, чтобы системные утилиты не путались
  file { '/etc/timezone':
    ensure  => file,
    content => "Asia/Dubai\n",
  }

}
