# teamviewer.pp - production POS installation

class teamviewer (
  String $user       = 'bit',
  String $pkg_source = 'https://download.teamviewer.com/download/linux/teamviewer_amd64.deb',
) {

  $deb_path = '/tmp/teamviewer_amd64.deb'

  # Проверка установлен ли TeamViewer
  $package_installed = "/usr/bin/dpkg-query -W -f='\${Status}' teamviewer 2>/dev/null | /bin/grep -qx 'install ok installed'"

  # Bootstrap (выполняется только если пакета нет)
  exec { 'download_teamviewer':
    command   => "/usr/bin/wget --tries=3 --timeout=30 -qO ${deb_path} ${pkg_source}",
    unless    => $package_installed,
    path      => ['/usr/bin', '/bin'],
    timeout   => 300,
    logoutput => on_failure,
  }

  exec { 'bootstrap_teamviewer':
    command     => "/usr/bin/apt-get -y install ${deb_path}",
    unless      => $package_installed,
    require     => Exec['download_teamviewer'],
    path        => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    timeout     => 600,
    logoutput   => on_failure,
    environment => ['DEBIAN_FRONTEND=noninteractive'],
  }

  # После bootstrap обновляем индекс APT.
  # Выполняется только если bootstrap действительно отработал.
  exec { 'apt_update_teamviewer':
    command     => '/usr/bin/apt-get update -qq',
    refreshonly => true,
    subscribe   => Exec['bootstrap_teamviewer'],
    path        => ['/usr/bin', '/usr/sbin'],
    timeout     => 300,
    logoutput   => on_failure,
  }

  # Далее Puppet полностью управляет пакетом через APT.
  package { 'teamviewer':
    ensure => latest,
  }


  # Сервис TeamViewer
  service { 'teamviewerd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['teamviewer'],
  }

  # Автозапуск TeamViewer для пользователя bit
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
    require => [
      Package['teamviewer'],
      File["/home/${user}/.config/autostart"],
    ],
    content => @("EOF")
[Desktop Entry]
Type=Application
Name=TeamViewer
Exec=/usr/bin/teamviewer
X-GNOME-Autostart-enabled=true
EOF
  }

  # Запуск TeamViewer для пользователя bit (только после установки)
  exec { 'start_teamviewer':
    command => "/usr/sbin/runuser -u ${user} -- bash -c 'export DISPLAY=:0; export XDG_RUNTIME_DIR=/run/user/1000; export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus; sleep 1; nohup /usr>
    path        => ['/usr/bin', '/bin'],
    logoutput   => false,
    refreshonly => true,
    subscribe   => Exec['bootstrap_teamviewer'],
    require     => [
      Service['teamviewerd'],
      File["/home/${user}/.config/autostart/TeamViewer.desktop"],
    ],
  }

  # Четкий порядок: bootstrap -> обновление APT -> установка пакета -> запуск сервиса
  Exec['bootstrap_teamviewer']
    -> Exec['apt_update_teamviewer']
    -> Package['teamviewer']
    -> Service['teamviewerd']

}
