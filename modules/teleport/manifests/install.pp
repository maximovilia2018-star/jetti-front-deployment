# modules/teleport/manifests/install.pp
#
# Устанавливает Teleport из официального репозитория.
# Поддерживает принудительную переустановку при recovery.
class teleport::install (
  String $install_version,
) {

  # Подготовка APT-репозитория Teleport: Скачиваем GPG-ключ Teleport (с защитой от поврежденного файла)
  exec { 'teleport_key_download':
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    #command => 'wget -qO - https://apt.releases.teleport.dev/gpg | gpg --dearmor -o /usr/share/keyrings/teleport-archive-keyring.gpg.tmp && mv /usr/share/keyrings/teleport-archive-keyring.gpg.tmp /usr/share/keyrings/teleport-archive-keyring.gpg',
    command => 'wget -qO - https://apt.releases.teleport.dev/gpg | ' .
               'gpg --dearmor -o /usr/share/keyrings/teleport-archive-keyring.gpg.tmp && ' .
               'mv /usr/share/keyrings/teleport-archive-keyring.gpg.tmp ' .
               '/usr/share/keyrings/teleport-archive-keyring.gpg',
    creates => '/usr/share/keyrings/teleport-archive-keyring.gpg',
  }

  # Добавляем репозиторий Teleport
  file { '/etc/apt/sources.list.d/teleport.list':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @("EOF"/L),
deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.gpg] https://apt.releases.teleport.dev/ubuntu ${facts['os']['distro']['codename']} stable/v${install_version}
| EOF
  }

  # Обновляем APT-кэш при изменении репозитория
  exec { 'teleport_apt_update':
    path        => ['/usr/bin', '/bin'],
    command     => 'apt-get update',
    refreshonly => true,
    timeout     => 120,
    tries       => 3,
    try_sleep   => 5,
  }

  # Установка Teleport
  package { 'teleport':
    ensure => present,
  }

  # Принудительная переустановка при recovery
  exec { 'teleport_force_reinstall':
    path        => ['/usr/bin', '/bin'],
    command     => 'apt-get install -y --reinstall teleport',
    refreshonly => true,
  }

  # Основной путь: установка через репозиторий
  Exec['teleport_key_download']
    -> File['/etc/apt/sources.list.d/teleport.list']
    ~> Exec['teleport_apt_update']
    -> Package['teleport']

  # Путь восстановления: принудительная переустановка
  # Восстановление инициирует recovery-модуль.
  Exec['run_teleport_recovery']
    ~> Exec['teleport_force_reinstall']
    -> Package['teleport']

}
