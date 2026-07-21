# modules/zabbix/manifests/init.pp
#
# Устанавливает и настраивает Zabbix Agent на POS-терминалах.
# Версия Zabbix берется из переменной $zabbix_version в site.pp.
# По умолчанию: '6.4'
class zabbix {
  # Установка Zabbix Agent
  $zbx_ver = pick($zbx_ver, $::zbx_ver, '6.4')
  $zbx_srv = pick($zbx_srv, $::zbx_srv, 'zabbix6active.x100group.com:10051')

  class { 'zabbix::install':
    zbx_ver => $zbx_ver,
  }

  # Настройка Zabbix Agent
  class { 'zabbix::config':
    zbx_srv => $zbx_srv,
  }

  # Цепочка зависимостей
  Class['zabbix::install']
    -> Class['zabbix::config']
}
