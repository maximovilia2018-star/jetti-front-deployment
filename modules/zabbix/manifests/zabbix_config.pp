class zabbix::zabbix_config {
  file { '/etc/zabbix':
        ensure  => directory,
        source  => 'puppet:///modules/zabbix',
        recurse => true,
        force   => true,
        require => Package['zabbix-agent'],
        notify  => Service['zabbix-agent']
  }

  file { '/etc/zabbix/zabbix_agentd.conf':
      require => Package['zabbix-agent'],
      notify  => Service['zabbix-agent'],
      ensure  => 'present',
      replace => 'yes',
      content => "PidFile=/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=100
Server=127.0.0.1
ServerActive=$zbx_srv
Hostname=$hostname
Include=/etc/zabbix/zabbix_agentd.d/*.conf
TLSConnect=psk
TLSAccept=psk
TLSPSKIdentity=PSK X100
TLSPSKFile=/etc/zabbix/zabbix_x100.psk
HostMetadata=x100_linux.autoreg",
  }

  file { '/etc/zabbix/zabbix_x100.psk':
      ensure  => 'present',
      replace => 'yes',
      content => '39a21b2b196da15d9d4ee4b53fcf82b8f55b2a8074fff30fb181581ea93a6032',
  }

  service { 'zabbix-agent':
    name => 'zabbix-agent',
    ensure  => 'running',
    enable  => true,
    hasrestart => true,
    require    => Package['zabbix-agent'],
  }

}
