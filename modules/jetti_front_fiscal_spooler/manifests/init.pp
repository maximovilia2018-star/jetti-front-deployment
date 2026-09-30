# modules/jetti_front_fiscal_spooler/manifests/init.pp
#
# Оптимизированный манифест установки фискального спулера для Puppet 8.
# Рассчитан строго на инфраструктуру Ubuntu 20.04 / 22.04.
#
class jetti_front_fiscal_spooler (
  $version,
  $githubtoken,
) {

  # Гарантируем, что базовый Nexus репозиторий подключен
  require profile::nexus_repo

  $down_hostname = downcase($::facts['networking']['hostname'])
  $config_path   = '/opt/jetti-front-fiscal-spooler/config.production.yaml'

  # Скачиваем GPG-ключ репозитория
  exec { 'add_nodesource_key':
    command => '/usr/bin/curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | /usr/bin/gpg --dearmor -o /usr/share/keyrings/nodesource.gpg',
    unless  => '/usr/bin/test -f /usr/share/keyrings/nodesource.gpg',
    before  => File['/etc/apt/sources.list.d/nodesource.list'],
  }

  # Формируем файл репозитория. Жесткий хардкод 'focal' решает проблему 404 на Jammy.
  file { '/etc/apt/sources.list.d/nodesource.list':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_14.x focal main\n",
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

  # ============================================================================
  # ДРАЙВЕРЫ ККМ АТОЛ И СИСТЕМНЫЕ ОБНОВЛЕНИЯ
  # Добавляем focal-updates для скачивания системных зависимостей АТОЛ
  file { '/etc/apt/sources.list.d/focal-updates.list':
    ensure  => file,
    replace => false,
    content => "deb http://ubuntu.com focal-updates main restricted universe multiverse\n",
    mode    => '0644',
    before  => [Package['libfptr10'], Package['libfptr10-gui'], Package['fptr10-test-util']],
  }

  # Установка пакетов драйверов
  package { ['libfptr10', 'libfptr10-gui', 'fptr10-test-util']:
    ensure => installed,
    before => Package['jetti-front-fiscal-spooler'],
  }

  # ============================================================================
  # УСТАНОВКА ПРИЛОЖЕНИЯ СПУЛЕРА
  # ============================================================================
  # Контролируем наличие пакета (заморожен на уровне ОС через APT preferences)
  package { 'jetti-front-fiscal-spooler':
    ensure => installed,
    noop   => true,
  }

  # ============================================================================
  # КОНФИГУРАЦИЯ И СЛУЖБА
  # ============================================================================

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
