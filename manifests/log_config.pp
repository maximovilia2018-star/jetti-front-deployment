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

  $user_atol_properties = '/home/bit/.atol/drivers10/fptr10_log.properties'
  $lib_atol_properties  = '/var/lib/AtolFptrWebServer/drivers10/fptr10_log.properties'

  file_line { 'Atol home log level':
    path  => $user_atol_properties,
    line  => 'logger.file.level=ERROR',
    match => '^logger\.file\.level\s*=',
    onlyif => "test -f ${user_atol_properties}",
  }

  file_line { 'Atol home log rotation days':
    path  => $user_atol_properties,
    line  => 'logger.file.period=2',
    match => '^logger\.file\.period\s*=',
    onlyif => "test -f ${user_atol_properties}",
  }

  file_line { 'Atol lib log level':
    path   => $lib_atol_properties,
    line   => 'logger.file.level=ERROR',
    match  => '^logger\.file\.level\s*=',
    onlyif => "test -f ${lib_atol_properties}",
  }
}
