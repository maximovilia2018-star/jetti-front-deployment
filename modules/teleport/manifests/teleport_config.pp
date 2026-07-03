class teleport::teleport_config {
  file { "/etc/rsyslog.d/13-teleport.conf":
    ensure  => 'present',
    replace => 'yes',
    content => ':rawmsg, contains, "teleport" /var/log/teleport.log\n&~',
    notify  => Service['rsyslog'],
  }

  file { "/etc/logrotate.d/teleport":
    notify  => Service['syslog'],
    ensure  => 'present',
    replace => 'yes',
    content => "/var/log/teleport.log {\n  rotate 7\n  daily\n  missingok\n  notifempty\n  compress\n  size 5M\n}",
  }
  
  file { '/etc/teleport.yaml':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      replace => 'yes',
      content => "version: v3
teleport:
  nodename: ${facts['networking']['hostname']}
  auth_token: 0c3a633af933fbb243a3a9f7fa37c347382f444e66ec3685
  data_dir: /var/lib/teleport
  proxy_server: teleport.x100group.com:443
  log:
    output: stderr
    severity: WARNING
    format:
      output: text
  ca_pin: sha256:7600b3aa6b6579796258000802fbcd9c2ed3dcdb7fb70124fcc94fb0e99879c5
  diag_addr: \"\"
auth_service:
  enabled: \"no\"
ssh_service:
  enabled: \"yes\"
  labels:
    env: \"${tele_env}\"
    group: \"${tele_group}\"
  commands:
  - name: hostname
    command: [hostname]
    period: 1m0s
proxy_service:
  enabled: \"no\"
  https_keypairs: []
  https_keypairs_reload_interval: 0s
  acme: {}",
  }

  service { 'teleport':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }

  service { 'rsyslog':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }

  exec { 'enable-teleport-managed-updates':
    path    => [ '/usr/bin', '/bin', '/usr/local/bin', '/opt/teleport/system/bin' ],
    command => '/opt/teleport/system/bin/teleport-update enable',
    user    => 'root',
    require => Service['teleport'],
    unless  => '/opt/teleport/system/bin/teleport-update status | grep -qi "enabled: true"',
  }

}
