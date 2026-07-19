# modules/zabbix/manifests/init.pp
#
# Устанавливает и настраивает Zabbix Agent на POS-терминалах.
# Версия Zabbix берется из переменной $zabbix_version в site.pp.
# По умолчанию: '6.4'

class zabbix (
  String $zabbix_version = pick($::zabbix_version, '6.4'),
){
  # Установка Zabbix Agent
  class { 'zabbix::install':
    zabbix_version => $zabbix_version,
  }

  # Настройка Zabbix Agent
  include zabbix::config

  # Цепочка зависимостей
  Class['zabbix::install']
    -> Class['zabbix::config']
}
