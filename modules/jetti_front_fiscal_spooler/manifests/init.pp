# modules/jetti_front_fiscal_spooler/manifests/init.pp
#
# Манифест установки фискального спулера для Puppet 8.
# Рассчитан на инфраструктуру Ubuntu 20.04 / 22.04.
#
class jetti_front_fiscal_spooler (
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
  # УСТАНОВКА ДРАЙВЕРОВ INGENICO (Замена ручной установки install.sh)
  # ============================================================================
  $lib_dir = '/usr/lib64'
  $drv_ver = '1.5.19'

  # Гарантируем, что папка /usr/lib64 физически существует в Ubuntu
  file { $lib_dir:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    before => File["${lib_dir}/libCommLibX.so.${drv_ver}"], # Папка должна быть ДО файлов
  }

  # Массив базовых имен библиотек
  $ingenico_libs = ['libCommLibX', 'libECRLibX', 'libBPOSLib']

  $ingenico_libs.each |$lib_name| {
    file { "${lib_dir}/${lib_name}.so.${drv_ver}":
      ensure => file,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => "puppet:///modules/jetti_front_fiscal_spooler/${lib_name}.so.${drv_ver}",
      # Драйвер обязан быть на диске ДО спулера
      before => Package['jetti-front-fiscal-spooler'],
      notify => Exec['ldconfig_update'],
    }
    # Создаем символическую ссылку (аналог команды ln -s -f)
    file { "${lib_dir}/${lib_name}.so":
      ensure => link,
      target => "${lib_dir}/${lib_name}.so.${drv_ver}",
      force  => true, # Ключ force принудительно перезапишет старые или битые ссылки
      before => Package['jetti-front-fiscal-spooler'],
      notify => Exec['ldconfig_update'],
    }
  }

  # Принудительно регистрируем папку /usr/lib64 в кэше линкера, чтобы ОС точно видела файлы
  exec { 'ldconfig_update':
    command     => '/sbin/ldconfig /usr/lib64',
    refreshonly => true,
    before      => Package['jetti-front-fiscal-spooler'],
  }
  
  # ============================================================================
  # УСТАНОВКА ПРИЛОЖЕНИЯ СПУЛЕРА
  # ============================================================================
  # Контролируем наличие пакета (заморожен на уровне ОС через APT preferences)
  package { 'jetti-front-fiscal-spooler':
    ensure => "$version",
    name => 'jetti-front-fiscal-spooler',
  }

  # Скачивание файла конфигурации напрямую из приватного репозитория GitHub
  #file { $config_path:
  #  ensure => file,
  #  owner  => 'root',
  #  group  => 'root',
  #  mode   => '0644',
  #  #source => "https://${githubtoken}@raw.githubusercontent.com/x100group/pos-configuration/main/fiscal-spooler/${down_hostname}/config.production.yaml",
  #  source => 'puppet:///modules/jetti_front_fiscal_spooler/config.production.yaml',
  #  notify => Service['jetti-front-fiscal-spooler'],
  #}

  # Контроль работы службы
  service { 'jetti-front-fiscal-spooler':
    ensure => 'running',
    enable => true,
  }

  # Строгая последовательность деплоя приложения
  #Package['jetti-front-fiscal-spooler'] -> File[$config_path] -> Service['jetti-front-fiscal-spooler']
  Package['jetti-front-fiscal-spooler'] -> Service['jetti-front-fiscal-spooler']
}
