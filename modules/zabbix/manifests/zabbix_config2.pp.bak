class zabbix::zabbix_config2 {
  file { '/etc/zabbix':
        ensure  => directory,
        source  => 'puppet:///modules/zabbix',
        recurse => true,
        force   => true,
        require => Package['zabbix-agent'],
        notify  => Service['zabbix-agent']
  }

  # Разный конфиг для разных версий Zabbix
  case $facts['os']['release']['major'] {
    /^(18|20)\.04$/: {
      # Старый конфиг для Zabbix 5.4
      file { '/etc/zabbix/zabbix_agentd.conf':
        require => Package['zabbix-agent'],
        notify  => Service['zabbix-agent'],
        ensure  => 'present',
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
    }
    
    /^(22|24)\.04$/: {
      # Новый конфиг для Zabbix 6.4
      file { '/etc/zabbix/zabbix_agentd.conf':
        require => Package['zabbix-agent'],
        notify  => Service['zabbix-agent'],
        ensure  => 'present',
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
HostMetadata=x100_linux.autoreg
# Zabbix 6.4 specific
HostMetadataItem=system.uname",
      }
    }
  }

  # PSK файл одинаков для всех версий
  file { '/etc/zabbix/zabbix_x100.psk':
    ensure  => 'present',
    owner   => 'zabbix',
    group   => 'zabbix',
    mode    => '0640',
    content => '39a21b2b196da15d9d4ee4b53fcf82b8f55b2a8074fff30fb181581ea93a6032',
    require => Package['zabbix-agent'],
    notify  => Service['zabbix-agent'],
  }

  # Service ресурс общий для всех
  service { 'zabbix-agent':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['zabbix-agent'],
  }
}
