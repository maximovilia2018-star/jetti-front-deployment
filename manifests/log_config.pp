class log_config {
  file { "/etc/rsyslog.d/15-atol-fptr.conf":
    ensure  => 'present',
    replace => 'yes',
    content => ':rawmsg, contains, "atol-fptr-web-server" /var/log/ATOL-fptr.log
&~'
 ,
  }

  file { "/etc/logrotate.d/ATOL-fptr":
    ensure  => 'present',
    replace => 'yes',
    content => "/var/log/ATOL-fptr.log {
    daily
    rotate 7
    compress
    #delaycompress
    missingok
    notifempty
    create 0640 syslog adm
}"
 ,
  }

  exec { 'Change to ERROR level fptr10 home properties':
    command => "/usr/bin/sed -i \'s/INFO/ERROR/g\' /home/bit/.atol/drivers10/fptr10_log.properties",
    onlyif  => "/usr/bin/grep INFO /home/bit/.atol/drivers10/fptr10_log.properties",
  }

  exec { 'Change two days log fptr10 home properties':
    command => "/usr/bin/sed -i \'s/=14/=2/g\' /home/bit/.atol/drivers10/fptr10_log.properties",
    onlyif  => "/usr/bin/grep 14 /home/bit/.atol/drivers10/fptr10_log.properties",
  }

  exec { 'Change to ERROR level  fptr10 lib properties':
    command => "/usr/bin/sed -i \'s/INFO/ERROR/g\' /var/lib/AtolFptrWebServer/drivers10/fptr10_log.properties",
    onlyif  => "/usr/bin/grep INFO /var/lib/AtolFptrWebServer/drivers10/fptr10_log.properties",
  }

#  cron { 'logrotate':
#    command => '/usr/sbin/logrotate',
#    ensure  => 'absent', 
#    ensure  => 'present', 
#    user    => 'root',
#    hour    => 1,
#    minute  => 3,
#  }

}
