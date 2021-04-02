node 'default' {

  $version = '1.3.0~alpha.5'

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

node 'ua-sm-posvishnevoe-01','ua-sm-poskiev-05a', 'ua-sm-poskiev-12a', 'ua-sm-poskiev-28', 'ua-sm-poskiev-01a', 'ua-sm-poskiev-11a', 'ua-sm-poskiev-13', 'ua-sm-poskiev-20b', 'ua-sm-poskiev-29', 'ua-sm-poskiev-25', 'ua-sm-posbucha-01a', 'ua-sm-posbrovary-01b' {

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
