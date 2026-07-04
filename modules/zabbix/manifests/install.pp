# modules/zabbix/manifests/install.pp
#
# Установка Zabbix Agent в зависимости от версии ОС.

class zabbix::install (
  String $zabbix_version,
){

  # Выбор метода установки в зависимости от версии Ubuntu
  case $facts['os']['release']['major'] {
    '24.04': {
      class { 'zabbix::install_ubuntu24':
        zabbix_version => $zabbix_version,
      }
    }
    default: {
      class { 'zabbix::install_default':
        zabbix_version => $zabbix_version,
      }
    }
  }

}
