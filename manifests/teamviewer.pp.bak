# teamviewer.pp - production POS installation (minimal & stable)
class teamviewer (
  String $user       = 'bit',
  String $pkg_source = 'https://download.teamviewer.com/download/linux/teamviewer_amd64.deb',
) {
  $deb_path = '/tmp/teamviewer_amd64.deb'
  
  # Проверка, что пакет действительно установлен
  $package_installed = "/usr/bin/dpkg-query -W -f='\${Status}' teamviewer 2>/dev/null | /bin/grep -q '^install ok installed$'"

  # Скачиваем пакет только если TeamViewer не установлен
  exec { 'download_teamviewer':
    command   => "/usr/bin/wget -qO ${deb_path} ${pkg_source}",
    unless    => $package_installed,
    path      => ['/usr/bin', '/bin'],
    logoutput => on_failure,
  }

  # Устанавливаем пакет, если он не установлен
  exec { 'install_teamviewer':
    command   => "/usr/bin/apt-get -y install ${deb_path}",
    unless    => $package_installed,
    require   => Exec['download_teamviewer'],
    path      => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    timeout   => 300,
    logoutput => on_failure,
  }

  # Удаляем .deb после установки
  exec { 'cleanup_teamviewer_deb':
    command     => "/bin/rm -f ${deb_path}",
    refreshonly => true,
    subscribe   => Exec['install_teamviewer'],
    path        => ['/bin', '/usr/bin'],
    logoutput   => on_failure,
  }

  # Сервис TeamViewer
  service { 'teamviewerd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Exec['install_teamviewer'],
  }

  # Создаём структуру каталогов для автозапуска
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

  # Настраиваем автозапуск TeamViewer
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
      Exec['install_teamviewer'],
      File["/home/${user}/.config/autostart"],
    ],
  }
}
