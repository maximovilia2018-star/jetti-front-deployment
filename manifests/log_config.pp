# log_config.pp - настройка логирования для ATOL-FPTR
#
# Настраивает:
# - rsyslog для сбора логов ATOL-fptr
# - logrotate для ротации логов ATOL-fptr
# - уровень логирования драйверов ATOL (INFO → ERROR)
# - срок хранения логов драйверов ATOL (14 дней → 2 дня)

class log_config {
  # Rsyslog конфигурация для ATOL-fptr
  file { '/etc/rsyslog.d/15-atol-fptr.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @("EOF")
:rawmsg, contains, "atol-fptr-web-server" /var/log/ATOL-fptr.log
&~
| EOF
  }

  # Logrotate конфигурация для ATOL-fptr
  file { '/etc/logrotate.d/ATOL-fptr':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    content => @("EOF")
/var/log/ATOL-fptr.log {
  daily
  rotate 7
  compress
  missingok
  notifempty
  create 0640 syslog adm
}
| EOF
  }

  if ! defined(Service['rsyslog']) {
    service { 'rsyslog':
      ensure     => running,
      enable     => true,
      hasrestart => true,
    }
  }

  # Настройка логирования драйверов ATOL для fptr10 home
  exec { 'fptr10_home_error_level':
    path    => ['/usr/bin', '/bin'],
    command => "/usr/bin/sed -i 's/INFO/ERROR/g' /home/bit/.atol/drivers10/fptr10_log.properties",
    onlyif  => "test -f /home/bit/.atol/drivers10/fptr10_log.properties && grep -q INFO /home/bit/.atol/drivers10/fptr10_log.properties",
  }

  # Изменение срока хранения логов для fptr10 home (14 → 2 дня)
  exec { 'fptr10_home_log_retention':
    path    => ['/usr/bin', '/bin'],
    command => "/usr/bin/sed -i 's/=14/=2/g' /home/bit/.atol/drivers10/fptr10_log.properties",
    onlyif  => "test -f /home/bit/.atol/drivers10/fptr10_log.properties && grep -q '=14' /home/bit/.atol/drivers10/fptr10_log.properties",
  }

  # Изменение уровня логирования для fptr10 lib
  exec { 'fptr10_lib_error_level':
    path    => ['/usr/bin', '/bin'],
    command => "/usr/bin/sed -i 's/INFO/ERROR/g' /var/lib/AtolFptrWebServer/drivers10/fptr10_log.properties",
    onlyif  => "test -f /var/lib/AtolFptrWebServer/drivers10/fptr10_log.properties && grep -q INFO /var/lib/AtolFptrWebServer/drivers10/fptr10_log.properties",
  }

  # Rsyslog конфиг → перезапуск rsyslog
  File['/etc/rsyslog.d/15-atol-fptr.conf']
    ~> Service['rsyslog']

}
