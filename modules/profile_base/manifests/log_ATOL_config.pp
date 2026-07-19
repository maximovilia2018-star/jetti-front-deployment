# log_ATOL_config.pp - настройка логирования для ATOL-FPTR
#
# Настраивает:
# - rsyslog конфигурацию для сбора логов ATOL-fptr
# - logrotate для ротации логов ATOL-fptr
# - уровень логирования драйверов ATOL (INFO → ERROR)
# - срок хранения логов драйверов ATOL (14 дней → 2 дня)
#
class profile_base::log_ATOL_config {
  # Единый путь для exec-ресурсов
  $default_path = ['/usr/bin', '/bin']

  # Объявляем службу rsyslog для применения изменений в конфигурации
  service { 'rsyslog':
    ensure     => running,
    enable     => true,
  }

  # Rsyslog конфигурация для ATOL-fptr (исправлен синтаксис &~ → stop)
  file { '/etc/rsyslog.d/15-atol-fptr.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @("EOF")
:rawmsg, contains, "atol-fptr-web-server" /var/log/ATOL-fptr.log
stop
| EOF,
    notify  => Service['rsyslog'], # Перезапускаем rsyslog при изменении конфига
  }

  # Logrotate конфигурация для ATOL-fptr
  file { '/etc/logrotate.d/ATOL-fptr':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/rsyslog.d/15-atol-fptr.conf'],
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

  # Настройка логирования драйверов ATOL (проверенный рабочий код)
  # Изменение уровня логирования для fptr10 home (INFO → ERROR)
  exec { 'fptr10_home_error_level':
    path    => $default_path,
    command => "sed -i 's/INFO/ERROR/g' /home/bit/.atol/drivers10/fptr10_log.properties",
    onlyif  => "test -f /home/bit/.atol/drivers10/fptr10_log.properties && grep -q INFO /home/bit/.atol/drivers10/fptr10_log.properties",
  }

  # Изменение срока хранения логов для fptr10 home (14 → 2 дня)
  exec { 'fptr10_home_log_retention':
    path    => $default_path,
    command => "sed -i 's/=14/=2/g' /home/bit/.atol/drivers10/fptr10_log.properties",
    onlyif  => "test -f /home/bit/.atol/drivers10/fptr10_log.properties && grep -q '=14' /home/bit/.atol/drivers10/fptr10_log.properties",
  }

  # Изменение уровня логирования для fptr10 lib (INFO → ERROR)
  exec { 'fptr10_lib_error_level':
    path    => $default_path,
    command => "sed -i 's/INFO/ERROR/g' /var/lib/AtolFptrWebServer/drivers10/fptr10_log.properties",
    onlyif  => "test -f /var/lib/AtolFptrWebServer/drivers10/fptr10_log.properties && grep -q INFO /var/lib/AtolFptrWebServer/drivers10/fptr10_log.properties",
  }

}
