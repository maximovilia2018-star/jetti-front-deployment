class zabbix_agent {
  exec { "install-zabbix-repository":
      command => "/usr/bin/wget https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian10_all.deb && dpkg -i zabbix-release_5.4-1+debian10_all.deb && apt update" ,
      user    => 'root',
      unless  => ["/bin/dpkg -s zabbix-agent | grep \'Version: \'"],
  }

  package { 'zabbix-agent':
    name => 'zabbix-agent',
  }

  file { '/var/log/zabbix':
    ensure => 'directory',
    owner => "zabbix",
    group => "zabbix",
  }

  file { '/etc/zabbix/zabbix_agentd.conf':
      ensure  => 'present',
      replace => 'yes',
      content => "PidFile=/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=100
Server=127.0.0.1
ServerActive=31.148.246.253:10049
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

}
