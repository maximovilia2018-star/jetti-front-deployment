class teleport::teleport_inst (
  String $install_version,
){

  exec { 'install-teleport-keyring':
    path    => [ '/usr/bin', '/bin' ],
    command => 'wget https://apt.releases.teleport.dev/gpg -O /usr/share/keyrings/teleport-archive-keyring.asc',
    user    => 'root',
    unless  => 'test -f /usr/share/keyrings/teleport-archive-keyring.asc',
    before  => File['/etc/apt/sources.list.d/teleport.list'],
  }

  file { '/etc/apt/sources.list.d/teleport.list':
    ensure  => present,
    mode    => '0640',
    content => "deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.asc] https://apt.releases.teleport.dev/ubuntu ${facts['os']['distro']['codename']} stable/v${install_version}\n",
  }

  exec { 'update-teleport-repository':
    path        => [ '/usr/bin', '/bin' ],
    command     => 'apt-get update',
    user        => 'root',
    refreshonly => true,
    subscribe   => File['/etc/apt/sources.list.d/teleport.list'],
  }

  package { 'teleport':
    ensure  => 'present',
    require => [ File['/etc/apt/sources.list.d/teleport.list'], Exec['update-teleport-repository'] ],
  }

  exec { 'force-reinstall-teleport-after-recovery':
    path        => [ '/usr/bin', '/bin' ],
    command     => 'apt-get install -y --reinstall teleport',
    user        => 'root',
    refreshonly => true,
    subscribe   => Exec['run-teleport-recovery'],
    before      => Package['teleport'],
  }
}
