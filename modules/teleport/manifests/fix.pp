class teleport::fix {

  $install_version = '16'
  $teleport_keyring = '/usr/share/keyrings/teleport-archive-keyring.gpg'

  exec { 'tele_fix_key_download':
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    command => "wget -qO - https://apt.releases.teleport.dev/gpg | gpg --dearmor -o ${teleport_keyring}.tmp && mv ${teleport_keyring}.tmp ${teleport_keyring}",
  }

  file { '/etc/apt/sources.list.d/teleport.list':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @("EOF")
deb [signed-by=${teleport_keyring}] https://apt.releases.teleport.dev/ubuntu ${facts['os']['distro']['codename']} stable/v${install_version}
| EOF
  }

  exec { 'tele_fix_apt_update':
    path      => ['/usr/bin', '/bin'],
    command   => 'apt-get update',
    timeout   => 300,
    tries     => 3,
    try_sleep => 5,
  }

  exec { 'tele_fix_force_reinstall':
    path    => ['/usr/bin', '/bin'],
    command => 'apt-get install -y --reinstall teleport',
    timeout => 300,
  }

  Exec['tele_fix_key_download']
    -> File['/etc/apt/sources.list.d/teleport.list']
    -> Exec['tele_fix_apt_update']
    -> Exec['tele_fix_force_reinstall']
}
