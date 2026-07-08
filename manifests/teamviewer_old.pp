# teamviewer.pp - production POS installation (minimal & stable)
class teamviewer (
  String $user    = 'bit',
  String $repo    = 'https://linux.teamviewer.com/deb',
  String $key_url = 'https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc',
) {
  $keyring    = '/usr/share/keyrings/teamviewer-keyring.gpg'
  $repo_file  = '/etc/apt/sources.list.d/teamviewer.list'

  exec { 'teamviewer_key_download':
    command => "/usr/bin/wget -qO - ${key_url} | /usr/bin/gpg --dearmor -o ${keyring}",
    creates => $keyring,
  }

  $teamviewer_orphaned_files = [
    "${repo_file}.dpkg-dist",
    "${repo_file}.dpkg-new",
    "${repo_file}.dpkg-divert",
  ]

  file { $teamviewer_orphaned_files:
    ensure => absent,
  }

  file { $repo_file:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "deb [signed-by=${keyring}] ${repo} stable main",
    require => Exec['teamviewer_key_download'],
    notify  => Exec['teamviewer_apt_update'],
  }

  exec { 'teamviewer_apt_update':
    command     => '/usr/bin/apt-get update',
    refreshonly => true,
    timeout     => 120,
    before      => Package['teamviewer'],
  }

  package { 'teamviewer':
    ensure  => installed,
    require => File[$repo_file],
  }

  service { 'teamviewerd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => Package['teamviewer'],
  }

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
