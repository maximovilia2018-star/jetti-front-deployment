# modules/zabbix/manifests/pip3_requirements.pp
#
# Установка Python3-пакетов, необходимых для скриптов мониторинга:
# - requests: для HTTP-запросов
# - firebase-admin: для работы с Firebase Firestore
#
# Все транзитивные зависимости устанавливаются автоматически через pip3.

class zabbix::pip3_requirements {

  # Установка pip3
  package { 'python3-pip':
    ensure => present,
  }

  # Python3-пакеты для скриптов мониторинга
  package { 'requests':
    ensure   => '2.26.0',
    provider => 'pip3',
    require  => Package['python3-pip'],
  }

  package { 'firebase-admin':
    ensure   => '5.0.3',
    provider => 'pip3',
    require  => Package['python3-pip'],
  }

}
