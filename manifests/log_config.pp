class log_config {
  file { '/etc/rsyslog.d/15-atol-fptr.conf':
    ensure  => 'present',
    replace => 'yes',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => ":rawmsg, contains, \"atol-fptr-web-server\" /var/log/ATOL-fptr.log\n&~",
    # Пинаем службу rsyslog
    notify  => Service['rsyslog'],
  }

  file { '/etc/logrotate.d/ATOL-fptr':
    ensure  => 'present',
    replace => 'yes',
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => "/var/log/ATOL-fptr.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 0640 syslog adm
}",
  }

  if ! defined(Service['rsyslog']) {
    service { 'rsyslog':
      ensure     => 'running',
      enable     => true,
      hasrestart => true,
    }
  }

  exec { 'Change to ERROR level fptr10 home properties':
    command => "/usr/bin/sed -i 's/INFO/ERROR/g' /home/bit/.atol/drivers10/fptr10_log.properties",
    onlyif  => "test -f /home/bit/.atol/drivers10/fptr10_log.properties && /usr/bin/grep -q INFO /home/bit/.atol/drivers10/fptr10_log.properties",
  }
  exec { 'Change two days log fptr10 home properties':
    command => "/usr/bin/sed -i 's/=14/=2/g' /home/bit/.atol/drivers10/fptr10_log.properties",
    onlyif  => "test -f /home/bit/.atol/drivers10/fptr10_log.properties && /usr/bin/grep -q '=14' /home/bit/.atol/drivers10/fptr10_log.properties",
  }
  exec { 'Change to ERROR level fptr10 lib properties':
    command => "/usr/bin/sed -i 's/INFO/ERROR/g' /var/lib/AtolFptrWebServer/drivers10/fptr10_log.properties",
    onlyif  => "test -f /var/lib/AtolFptrWebServer/drivers10/fptr10_log.properties && /usr/bin/grep -q INFO /var/lib/AtolFptrWebServer/drivers10/fptr10_log.properties",
  }
}
