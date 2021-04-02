node 'default' {

  $version = '1.3.0~alpha.3'

  file { '/etc/apt/sources.list.d/x100.list':
      ensure  => 'present',
      replace => 'no',
      content => 'deb [trusted=yes] https://repository.jfd-prod.x100platforma.com/artifactory/debian x100 front',
      mode    => '0644',
  }

  file { '/home/bit/.config/autostart/x100-front.desktop':
      ensure  => 'present',
      replace => 'yes',
      content => '[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=CashDesk
Comment=Cash Desk Sushi Master
Exec=jetti-front
Hidden=false
NoDisplay=false
Terminal=false',
      mode    => '0644',
  }

  package { 'bit-cash-box':
    ensure => 'purged',
    name => 'bit-cash-box',
  }

  exec { 'apt-get-update':
    command => "apt-get update -o Dir::Etc::sourcelist='sources.list.d/x100.list' -o Dir::Etc::sourceparts='-' -o APT::Get::List-Cleanup='0'",
    onlyif  => "wget -q -N -P /tmp https://repository.jfd-prod.x100platforma.com:443/artifactory/debian/dists/x100/Release && ! cmp -s /tmp/Release /var/lib/apt/lists/repository.jfd-prod.x100platforma.com_artifactory_debian_dists_x100_Release",
    path    => [ '/usr/bin', '/bin' ],
  }

  package { 'jetti-front':
    ensure => "$version",
    name => 'jetti-front',
  }

  package { 'unattended-upgrades':
    ensure => 'purged',
    name => 'unattended-upgrades',
  }
}

node 'ua-sm-poskharkiv-05', 'ua-sm-poskiev-04', 'ua-sm-poskiev-35', 'ua-sm-poskiev-30a', 'ua-sm-poskiev-23', 'ua-sm-poskiev-26', 'ua-sm-poskiev-06', 'ua-sm-posyuzhnoukrainsk-01', 'ua-sm-poskharkiv-06', 'ua-sm-poskiev-34', 'ua-sm-poskiev-10', 'ua-sm-poskiev-09', 'ua-sm-poskiev-19a', 'ua-sm-poskiev-18', 'ua-sm-poskiev-03', 'ua-sm-poskiev-15', 'ua-sm-poskiev-33', 'ua-sm-poskiev-16', 'ua-sm-poskiev-17', 'ua-sm-posgostomel-01', 'ua-sm-posnikolaev-01', 'ua-sm-poskiev-39', 'ua-sm-poskiev-21', 'ua-sm-posukrainka-01', 'ua-sm-poskiev-27a', 'ua-sm-poskiev-31', 'ua-sm-poskiev-32', 'ua-sm-posboryspil-01' {

  $version = '1.3.1'

  file { '/etc/apt/sources.list.d/x100.list':
      ensure  => 'present',
      replace => 'no',
      content => 'deb [trusted=yes] https://repository.jfd-prod.x100platforma.com/artifactory/debian x100 front',
      mode    => '0644',
  }

  file { '/home/bit/.config/autostart/x100-front.desktop':
      ensure  => 'present',
      replace => 'yes',
      content => '[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=CashDesk
Comment=Cash Desk Sushi Master
Exec=jetti-front
Hidden=false
NoDisplay=false
Terminal=false',
      mode    => '0644',
  }

  package { 'bit-cash-box':
    ensure => 'purged',
    name => 'bit-cash-box',
  }

  exec { 'apt-get-update':
    command => "apt-get update -o Dir::Etc::sourcelist='sources.list.d/x100.list' -o Dir::Etc::sourceparts='-' -o APT::Get::List-Cleanup='0'",
    onlyif  => "wget -q -N -P /tmp https://repository.jfd-prod.x100platforma.com:443/artifactory/debian/dists/x100/Release && ! cmp -s /tmp/Release /var/lib/apt/lists/repository.jfd-prod.x100platforma.com_artifactory_debian_dists_x100_Release",
    path    => [ '/usr/bin', '/bin' ],
  }

  package { 'jetti-front':
    ensure => "$version",
    name => 'jetti-front',
  }

  package { 'unattended-upgrades':
    ensure => 'purged',
    name => 'unattended-upgrades',
  }
}

node 'ua-sm-poskropyvnytskyi-02' {

  $version = '1.3.3'

  file { '/etc/apt/sources.list.d/x100.list':
      ensure  => 'present',
      replace => 'no',
      content => 'deb [trusted=yes] https://repository.jfd-prod.x100platforma.com/artifactory/debian x100 front',
      mode    => '0644',
  }

  file { '/home/bit/.config/autostart/x100-front.desktop':
      ensure  => 'present',
      replace => 'yes',
      content => '[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=CashDesk
Comment=Cash Desk Sushi Master
Exec=jetti-front
Hidden=false
NoDisplay=false
Terminal=false',
      mode    => '0644',
  }

  package { 'bit-cash-box':
    ensure => 'purged',
    name => 'bit-cash-box',
  }

  exec { 'apt-get-update':
    command => "apt-get update -o Dir::Etc::sourcelist='sources.list.d/x100.list' -o Dir::Etc::sourceparts='-' -o APT::Get::List-Cleanup='0'",
    onlyif  => "wget -q -N -P /tmp https://repository.jfd-prod.x100platforma.com:443/artifactory/debian/dists/x100/Release && ! cmp -s /tmp/Release /var/lib/apt/lists/repository.jfd-prod.x100platforma.com_artifactory_debian_dists_x100_Release",
    path    => [ '/usr/bin', '/bin' ],
  }

  package { 'jetti-front':
    ensure => "$version",
    name => 'jetti-front',
  }

  package { 'unattended-upgrades':
    ensure => 'purged',
    name => 'unattended-upgrades',
  }
}
