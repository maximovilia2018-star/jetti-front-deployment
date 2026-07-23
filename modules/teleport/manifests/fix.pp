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
set -e

systemctl stop teleport || true
apt-get purge -y teleport || true

rm -rf /opt/teleport
rm -rf /var/lib/teleport
rm -rf /etc/systemd/system/teleport.service.d
rm -rf /etc/systemd/system/teleport.service.wants
rm -f /etc/systemd/system/teleport*

systemctl daemon-reload

apt-get update -qq
apt-get install -y teleport
| EOF
  }

  exec { 'root_fix_sh':
    command => '/root/fix.sh',
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    timeout => 600,
  }

  File['/etc/apt/sources.list.d/teleport.list']
    -> File['/root/fix.sh']
    -> Exec['root_fix_sh']
}
