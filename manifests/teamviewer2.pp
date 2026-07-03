# teamviewer.pp - production POS installation (minimal & stable)
class teamviewer2 (
  String $user = 'bit',
) {
  exec { 'teamviewer_key_download':
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    command => 'wget -qO - https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc | gpg --dearmor -o /usr/share/keyrings/teamviewer-keyring.gpg',
    creates => '/usr/share/keyrings/teamviewer-keyring.gpg',
  }

  $teamviewer_orphaned_files = [
    '/etc/apt/sources.list.d/teamviewer.list.dpkg-dist',
    '/etc/apt/sources.list.d/teamviewer.list.dpkg-new',
    '/etc/apt/sources.list.d/teamviewer.list.dpkg-divert',
  ]

  file { $teamviewer_orphaned_files:
    ensure => absent,
  }

  file { '/etc/apt/sources.list.d/teamviewer.list':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => 'deb [signed-by=/usr/share/keyrings/teamviewer-keyring.gpg] https://linux.teamviewer.com/deb stable main',
    replace => true,
    require => Exec['teamviewer_key_download'],
    notify  => Exec['teamviewer_apt_update'],
  }

  exec { 'teamviewer_apt_update':
    path    => ['/usr/bin', '/bin'],
    command => 'apt-get update',
    unless  => 'dpkg -l teamviewer 2>/dev/null | grep -q "^ii"',
    timeout => 120,
    require => File['/etc/apt/sources.list.d/teamviewer.list'],
  }

  package { 'teamviewer':
    ensure  => installed,
    require => Exec['teamviewer_apt_update'],
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
