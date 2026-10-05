# modules/profile/manifests/base_soft.pp
class profile::base_soft {

  package { ['unattended-upgrades', 'bit-cash-box', 'lubuntu-update-notifier']:
    ensure  => purged,
  }

  # Базовый набор утилит для POS
  $required_tools = [
    'ca-certificates',
    'curl',
    'gnupg',
    'htop',
    'jq',
    'mc',
    'wget',
  ]

  package { $required_tools:
    ensure  => present,
    require => Package['unattended-upgrades'],
  }

  # Удаляем старый дефолтный файл хука Canonical
  file { '/etc/apt/apt.conf.d/20apt-esm-hook':
    ensure => absent,
  }

  # Создаем единый чистый конфигурационный файл для скрытия баннеров ESM
  file { '/etc/apt/apt.conf.d/99disable-pro-ads.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "Apt::Notification::Ubuntu-Pro::ESM-Apps-Security-Status \"hidden\";\nApt::Notification::Ubuntu-Pro::ESM-Infra-Security-Status \"hidden\";\n",
  }

  # Специфичная очистка для Ubuntu 22.04 (Jammy)
  #if $facts['os']['release']['major'] == '22.04' {
    # Создаем директорию для конфига клиента, если её еще нет
  #  file { '/etc/ubuntu-pro-client':
  #    ensure => directory,
  #    owner  => 'root',
  #    group  => 'root',
  #    mode   => '0755',
  #  }

  #  file { '/etc/ubuntu-pro-client/v1':
  #    ensure  => directory,
  #    owner   => 'root',
  #    group   => 'root',
  #    mode    => '0755',
  #    require => File['/etc/ubuntu-pro-client'],
  #  }

    # Отключаем Apt News и статус ESM в самом клиенте Ubuntu Pro
  #  file { '/etc/ubuntu-pro-client/v1/tm.json':
  #    ensure  => file,
  #    owner   => 'root',
  #    group   => 'root',
  #    mode    => '0644',
  #    content => '{"messages": {"apt_news": false, "esm_status": false}}',
  #    require => File['/etc/ubuntu-pro-client/v1'],
  #  }
  #}
}
