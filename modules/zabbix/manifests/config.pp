# modules/zabbix/manifests/config.pp
#
# Настройка Zabbix Agent.

class zabbix::config {

  # Переменные из верхнего scope
  #$zbx_srv = pick($::zbx_srv, 'zabbix6active.x100group.com:10051')

  # Директория конфигурации
  file { '/etc/zabbix':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  # Каталог дополнительных конфигураций
  file { '/etc/zabbix/zabbix_agentd.d':
    ensure  => directory,
    source  => 'puppet:///modules/zabbix/zabbix_agentd.d',
    recurse => true,
    purge   => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File['/etc/zabbix'],
    notify  => Service['zabbix-agent'],
  }

  # PSK-ключ для TLS шифрования
  file { '/etc/zabbix/zabbix_x100.psk':
    ensure  => file,
    owner   => 'zabbix',
    group   => 'zabbix',
    mode    => '0600',
    content => '39a21b2b196da15d9d4ee4b53fcf82b8f55b2a8074fff30fb181581ea93a6032',
    require => File['/etc/zabbix'],
    notify  => Service['zabbix-agent'],
  }

  # Основной конфигурационный файл
  file { '/etc/zabbix/zabbix_agentd.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @("EOF"),
PidFile=/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=100
Server=127.0.0.1
ServerActive=${zbx_srv}
ServerActive=$zbx_srv
Hostname=${facts['networking']['hostname']}
Include=/etc/zabbix/zabbix_agentd.d/*.conf
TLSConnect=psk
TLSAccept=psk
TLSPSKIdentity=PSK X100
TLSPSKFile=/etc/zabbix/zabbix_x100.psk
HostMetadata=x100_linux.autoreg
| EOF
    require => File['/etc/zabbix'],
    notify  => Service['zabbix-agent'],
  }
  
  # Сервис Zabbix Agent
  service { 'zabbix-agent':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['zabbix-agent'],
  }
}
