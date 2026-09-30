# modules/jetti_front_fiscal_spooler/manifests/init.pp
#
# Манифест установки фискального спулера для Puppet 8.
# Рассчитан на инфраструктуру Ubuntu 20.04 / 22.04.
#
class jetti_front_fiscal_spooler::v2 (
  $version,
  $githubtoken,
) {

  require profile::nexus_repo

  $down_hostname = downcase($::facts['networking']['hostname'])
  $config_path   = '/opt/jetti-front-fiscal-spooler/config.production.yaml'

  # ============================================================================
  # УСТАНОВКА NODE.JS 14
  # ============================================================================
  # Скачиваем GPG-ключ репозитория
  file { '/usr/share/keyrings/nodesource.gpg':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/jetti_front_fiscal_spooler/nodesource.gpg',
    before => File['/etc/apt/sources.list.d/nodesource.list'],
  }

  # Формируем файл репозитория. Жесткий хардкод 'focal' решает проблему 404 на Jammy.
  file { '/etc/apt/sources.list.d/nodesource.list':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "deb [signed-by=/usr/share/keyrings/nodesource.gpg AllowWeak=yes] https://deb.nodesource.com/node_14.x focal main\n",
    notify  => Exec['apt_update_nodesource'],
  }

  # Обновляем кэш APT только если изменился или создался list-файл
  exec { 'apt_update_nodesource':
    command     => '/usr/bin/apt-get update',
    refreshonly => true,
    before      => Package['nodejs'],
  }

  # Устанавливаем сам Node.js 14
  package { 'nodejs':
    ensure => installed,
    before => Package['jetti-front-fiscal-spooler'],
  }

  # Отключение автообновления (apt upgrade)
  file { '/etc/apt/preferences.d/jetti-front-fiscal-spooler.pref':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/fiscal_ua/jetti-front-fiscal-spooler.pref',
  }

  # ============================================================================
  # УСТАНОВКА ПРИЛОЖЕНИЯ СПУЛЕРА
  # ============================================================================
  # Контролируем наличие пакета (заморожен на уровне ОС через APT preferences)
  package { 'jetti-front-fiscal-spooler':
    ensure => installed,
    noop   => true,
  }

  # Скачивание файла конфигурации напрямую из приватного репозитория GitHub
  file { $config_path:
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0600',
    source => "https://${githubtoken}@raw.githubusercontent.com/x100group/pos-configuration/main/fiscal-spooler/${down_hostname}/config.production.yaml",
    notify => Service['jetti-front-fiscal-spooler'],
  }

  # Контроль работы службы
  service { 'jetti-front-fiscal-spooler':
    ensure => 'running',
    enable => true,
  }

  # Строгая последовательность деплоя приложения
  Package['jetti-front-fiscal-spooler'] -> File[$config_path] -> Service['jetti-front-fiscal-spooler']
}
