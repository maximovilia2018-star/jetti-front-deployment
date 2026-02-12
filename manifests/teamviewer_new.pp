class teamviewer_new {
  package { ['wget', 'ca-certificates']:
    ensure => installed,
  }

  file { '/usr/share/keyrings':
    ensure => directory,
    mode   => '0755',
  }

  exec { 'download-teamviewer-key':
    command => '/usr/bin/wget -qO- https://download.teamviewer.com/download/linux/teamviewer.pub | /usr/bin/gpg --dearmor > /usr/share/keyrings/teamviewer-keyring.gpg',
    creates => '/usr/share/keyrings/teamviewer-keyring.gpg',
    path    => ['/usr/bin', '/bin'],
    require => [Package['wget'], File['/usr/share/keyrings']],
  }

  file { '/etc/apt/sources.list.d/teamviewer.list':
    ensure  => file,
    content => 'deb [signed-by=/usr/share/keyrings/teamviewer-keyring.gpg] https://linux.teamviewer.com/deb stable main',
    mode    => '0644',
    require => Exec['download-teamviewer-key'],
  }

  exec { 'apt-update-teamviewer':
    command     => '/usr/bin/apt-get update',
    subscribe   => File['/etc/apt/sources.list.d/teamviewer.list'],
    refreshonly => true,
  }

  package { 'teamviewer':
    ensure  => 'latest',
    require => [File['/etc/apt/sources.list.d/teamviewer.list'], Exec['apt-update-teamviewer']],
  }

  file { '/home/bit/.config':
    ensure => directory,
    owner  => 'bit',
    group  => 'bit',
    mode   => '0755',
  }

  file { '/home/bit/.config/autostart':
    ensure  => directory,
    owner   => 'bit',
    group   => 'bit',
    mode    => '0755',
    require => File['/home/bit/.config'],
  }

  file { '/home/bit/.config/autostart/TeamViewer.desktop':
    ensure  => file,
    owner   => 'bit',
    group   => 'bit',
    mode    => '0644',
    content => @("END"),
[Desktop Entry]
Exec=/opt/teamviewer/tv_bin/script/teamviewer
Name=TeamViewer
Type=Application
Version=1.0
X-GNOME-Autostart-enabled=true
| END
    require => [Package['teamviewer'], File['/home/bit/.config/autostart']],
  }
}
