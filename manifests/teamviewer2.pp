# teamviewer.pp - production POS installation (minimal & stable)
# Без зависимости от puppetlabs-apt

class teamviewer2 (
  String $user = 'bit',
) {

  package { 'apt-transport-https':
    ensure => installed,
  }

  # =========================================================================
  # Скачивание GPG-ключа TeamViewer
  # =========================================================================

  exec { 'teamviewer_key_download':
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    command => 'wget -qO - https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc | apt-key add -',
    unless  => 'apt-key list | grep -q "TeamViewer"',
    require => Package['apt-transport-https'],
  }

  # =========================================================================
  # Добавление репозитория TeamViewer
  # =========================================================================

  file { '/etc/apt/sources.list.d/teamviewer.list':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => 'deb https://download.teamviewer.com/deb stable main',
    require => Exec['teamviewer_key_download'],
    notify  => Exec['teamviewer_apt_update'],
  }

  # =========================================================================
  # Обновление APT-кэша
  # =========================================================================

  exec { 'teamviewer_apt_update':
    path        => ['/usr/bin', '/bin'],
    command     => 'apt-get update',
    refreshonly => true,
    require     => File['/etc/apt/sources.list.d/teamviewer.list'],
  }

  # =========================================================================
  # Установка TeamViewer
  # =========================================================================

  package { 'teamviewer':
    ensure  => latest,
    require => Exec['teamviewer_apt_update'],
  }

  # =========================================================================
  # Сервис
  # =========================================================================

  service { 'teamviewerd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => Package['teamviewer'],
  }

  # =========================================================================
  # Автозапуск для пользователя
  # =========================================================================

  file { "/home/${user}/.config":
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0755',
  }

  file { "/home/${user}/.config/autostart":
    ensure  => directory,
    owner   => $user,
    group   => $user,
    mode    => '0755',
    require => File["/home/${user}/.config"],
  }

  file { "/home/${user}/.config/autostart/TeamViewer.desktop":
    ensure  => file,
    owner   => $user,
    group   => $user,
    mode    => '0644',
    content => "[Desktop Entry]
Type=Application
Name=TeamViewer
Exec=/usr/bin/teamviewer
X-GNOME-Autostart-enabled=true
",
    require => [
      Package['teamviewer'],
      File["/home/${user}/.config/autostart"],
    ],
  }

}
