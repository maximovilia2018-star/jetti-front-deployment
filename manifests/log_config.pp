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

#  cron { 'logrotate':
#    command => '/usr/sbin/logrotate',
#    ensure  => 'absent', 
#    ensure  => 'present', 
#    user    => 'root',
#    hour    => 1,
#    minute  => 3,
#  }

}
