class profile::nexus_repo {

  $nexus_domain = 'nexus.x100group.com'

  # 1. Фикс проверки SSL-сертификата Sectigo для локального процесса APT
  file { '/etc/apt/apt.conf.d/99nexus-ssl':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "Acquire::https::${nexus_domain}::Verify-Peer \"false\";\nAcquire::https::${nexus_domain}::Verify-Host \"false\";\n",
  }

  # 2. Копирование готового скомпилированного бинарного PGP-ключ подписи пакетов
  file { '/usr/share/keyrings/x100.gpg':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/profile/x100.gpg',
    notify => Exec['apt_update_nexus'],
  }

  # 3. Обновление кэша APT при изменении конфигураций
  exec { 'apt_update_nexus':
    command     => '/usr/bin/apt-get update',
    refreshonly => true,
  }
}
