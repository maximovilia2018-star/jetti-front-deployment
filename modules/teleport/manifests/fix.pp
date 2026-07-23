class teleport::fix {

  $install_version = '16'
  $teleport_keyring = '/usr/share/keyrings/teleport-archive-keyring.gpg'

  file { '/etc/apt/sources.list.d/teleport.list':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @("EOF")
deb [signed-by=${teleport_keyring}] https://apt.releases.teleport.dev/ubuntu ${facts['os']['distro']['codename']} stable/v${install_version}
| EOF
  }

  file { '/root/fix.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => @("EOF")
#!/bin/bash

systemctl stop teleport
apt-get remove -y teleport
#echo "deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.gpg] https://apt.releases.teleport.dev/ubuntu jammy stable/v16" > /etc/apt/sources.list.d/teleport.list
apt-get update -qq

rm -rf /opt/teleport
rm -rf /var/lib/teleport
rm -rf /etc/systemd/system/teleport.service.d
rm -rf /etc/systemd/system/teleport.service.wants
rm -f /etc/systemd/system/teleport*

apt-get install -y teleport
| EOF
  }

  exec { 'root_fix_sh':
    path    => ['/usr/bin', '/bin'],
    command => '/root/fix.sh',
    timeout => 300,
  }

  Exec['root_fix_sh']
    -> File['/etc/apt/sources.list.d/teleport.list']
    -> Exec['/root/fix.sh']
}
