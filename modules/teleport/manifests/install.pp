# modules/teleport/manifests/install.pp
#
# Устанавливает Teleport из официального репозитория.
# Поддерживает принудительную переустановку при recovery.
class teleport::install (
  String $install_version,
) {

  # Подготовка APT-репозитория Teleport: Скачиваем GPG-ключ Teleport (с защитой от поврежденного файла)
  $teleport_keyring = '/usr/share/keyrings/teleport-archive-keyring.gpg'
  exec { 'teleport_key_download':
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    command => "wget -qO - https://apt.releases.teleport.dev/gpg | gpg --dearmor -o ${teleport_keyring}.tmp && mv ${teleport_keyring}.tmp ${teleport_keyring}",
    creates => "${teleport_keyring}",
  }

  # Добавляем репозиторий Teleport
  file { '/etc/apt/sources.list.d/teleport.list':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @("EOF")
deb [signed-by=${teleport_keyring}] https://apt.releases.teleport.dev/ubuntu ${facts['os']['distro']['codename']} stable/v${install_version}
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
  # обновлением Teleport управляет встроенный teleport-update.
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
