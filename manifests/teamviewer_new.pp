class teamviewer_new {
  package { ['wget', 'gpg']:
    ensure => installed,
  }

  exec { 'download-teamviewer':
    command => '/usr/bin/wget -O /tmp/teamviewer.deb https://download.teamviewer.com/download/linux/teamviewer_amd64.deb',
    creates => '/tmp/teamviewer.deb',
    path    => ['/usr/bin', '/bin'],
    require => Package['wget'],
  }

  package { 'teamviewer':
    provider => 'dpkg',
    source   => '/tmp/teamviewer.deb',
    require  => Exec['download-teamviewer'],
  }

  # Автозапуск для користувача bit
  file { ['/home/bit/.config', '/home/bit/.config/autostart']:
    ensure => directory,
    owner  => 'bit',
    group  => 'bit',
    mode   => '0755',
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
