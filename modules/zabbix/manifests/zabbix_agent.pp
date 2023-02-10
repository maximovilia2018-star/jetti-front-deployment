class zabbix::zabbix_agent {
  exec { "install-zabbix-repository":
      command => "/usr/bin/wget https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian10_all.deb && dpkg -i zabbix-release_5.4-1+debian10_all.deb && apt update" ,
      user    => 'root',
      unless  => ["/bin/dpkg -s zabbix-agent | grep \'Version: \'"],
  }

  package { 'zabbix-agent':
    name => 'zabbix-agent',
  }

  exec { 'remove zabbix-release.deb':
    path    => [ '/usr/bin', '/bin' ],
    command => "rm -f zabbix-release_5.4-1+debian10_all.*",
    onlyif  => ["ls -l zabbix-release_5.4-1+debian10_all.*"],
  }

  file { '/var/log/zabbix':
    ensure => 'directory',
    owner => "zabbix",
    group => "zabbix",
  }

}
