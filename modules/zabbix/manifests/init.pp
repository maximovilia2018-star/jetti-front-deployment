# modules/zabbix/manifests/init.pp
#
# Устанавливает и настраивает Zabbix Agent на POS-терминалах.
# Версия Zabbix берется из переменной $zabbix_version в site.pp.
# По умолчанию: '6.4'
class zabbix {
  # Установка Zabbix Agent
  $version = $zabbix_version ? {
    undef   => '6.4',           # Если в site.pp её нет, берем дефолт
    default => $zabbix_version, # Если есть, берем её значение
  }

  class { 'zabbix::install':
    zabbix_version => $version,
  }

  # Настройка Zabbix Agent
  class { 'zabbix::config':
    zbx_srv => $zbx_srv,
  }


  # Цепочка зависимостей
  Class['zabbix::install']
    -> Class['zabbix::config']
}
