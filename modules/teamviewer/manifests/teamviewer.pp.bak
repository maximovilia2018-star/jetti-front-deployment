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
    timeout   => 300,
    logoutput => on_failure,
  }

  # Устанавливаем из .deb только если пакет отсутствует (bootstrap)
  exec { 'bootstrap_teamviewer':
    command   => "/usr/bin/apt-get -y install ./teamviewer_amd64.deb",
    cwd       => '/tmp',
    unless    => $package_installed,
    require   => Exec['download_teamviewer'],
    path      => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
    timeout   => 300,
    logoutput => on_failure,
  }

  # Обновляем индекс APT только после успешного bootstrap.
  # На обычных запусках Puppet этот ресурс не выполняется.
  exec { 'apt_update_after_bootstrap':
    command     => '/usr/bin/apt-get update',
    refreshonly => true,
    subscribe   => Exec['bootstrap_teamviewer'],
    path        => ['/usr/bin', '/usr/sbin'],
    timeout     => 300,
    logoutput   => on_failure,
  }

  # Строгий порядок: Локальная установка -> Апдейт кэша -> Передача управления в Puppet Package
  Exec['bootstrap_teamviewer']
    -> Exec['apt_update_after_bootstrap']
    -> Package['teamviewer']
    -> Service['teamviewerd']

  # Если после установки отсутствует /etc/apt/sources.list.d/teamviewer.list, проверить и удалить блокировку
  # dpkg-divert --list /etc/apt/sources.list.d/teamviewer.list
  # dpkg-divert --rename --remove /etc/apt/sources.list.d/teamviewer.list

  # Теперь Puppet управляет пакетом через репозиторий.
  package { 'teamviewer':
    ensure => latest,
  }

  # Сервис TeamViewer
  service { 'teamviewerd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  # Автозапуск
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
