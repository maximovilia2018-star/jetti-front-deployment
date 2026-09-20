# modules/zabbix/manifests/init.pp
#
# Устанавливает и настраивает Zabbix Agent на POS-терминалах.
# Версия Zabbix берется из переменной $zabbix_version в site.pp.
# По умолчанию: '6.4'
class zabbix (
  # Разрешаем принимать undef, если параметры не переданы явно
  Optional[String] $zabbix_ver = undef,
  Optional[String] $zabbix_srv = undef,
) {
  # Установка Zabbix Agent
  $version = pick(getvar('zbx_ver'), '6.4')
  $zserver = pick(getvar('zbx_srv'), 'zabbix6active.x100group.com:10051')

  class { 'zabbix::install':
    zbx_ver => $version,
  }

  # Настройка Zabbix Agent
  class { 'zabbix::config':
    zbx_srv => $zserver,
  }

  # Цепочка зависимостей
  Class['zabbix::install']
    -> Class['zabbix::config']
}
