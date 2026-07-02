class teamviewer {

  # https://download.teamviewer.com/download/linux/teamviewer_amd64.deb
  $deb_file = 'teamviewer_amd64.deb'
  $download_url = "https://download.teamviewer.com/download/linux/${deb_file}"
  $local_path = "/tmp/${deb_file}"

  if ! defined(Package['wget']) {
    package { 'wget': ensure => installed }
  }

  exec { 'download-teamviewer-deb':
    path    => ['/usr/bin', '/bin'],
    command => "wget -q -O ${local_path} ${download_url}",
    unless  => '/usr/bin/dpkg-query -W -f=\'${Status}\' teamviewer 2>/dev/null | grep -q "install ok installed"',
    require => Package['wget'],
  }

  exec { 'install-teamviewer-package':
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    command => "/usr/bin/apt-get update && /usr/bin/apt-get -y -o DPkg::Options::=--force-confold install ${local_path}",
    user    => 'root',
    unless  => '/usr/bin/dpkg-query -W -f=\'${Status}\' teamviewer 2>/dev/null | grep -q "install ok installed"',
    require => Exec['download-teamviewer-deb'],
    before  => Service['teamviewerd'],
  }

  exec { 'cleanup-teamviewer-deb':
    path    => ['/usr/bin', '/bin'],
    command => "rm -f ${local_path}",
    onlyif  => "test -f ${local_path}",
    require => Exec['install-teamviewer-package'],
  }

  service { 'teamviewerd':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }

  file { '/home/bit/.config/autostart':
    ensure   => 'directory',
    owner    => 'bit',
    group    => 'bit',
    mode     => '0755',
    makepath => true,
  }

  file { '/home/bit/.config/autostart/TeamViewer.desktop':
    ensure  => 'present',
    replace => 'yes',
    owner   => 'bit',
    group   => 'bit',
    mode    => '0644',
    content => "[Desktop Entry]
Exec=/opt/teamviewer/tv_bin/script/teamviewer
Name=TeamViewer
Type=Application
Version=1.0
X-GNOME-Autostart-enabled=true
",
    require => [ Exec['install-teamviewer-package'], File['/home/bit/.config/autostart'] ],
  }

}
