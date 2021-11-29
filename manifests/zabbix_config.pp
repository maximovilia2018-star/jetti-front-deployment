class zabbix_config {
  file { '/etc/zabbix':
        ensure  => directory,
        source  => 'puppet:///modules/zabbix',
        recurse => true,
        force   => true,
        require => Package['zabbix-agent'],
        notify  => Service['zabbix-agent']
  }

  service { 'zabbix-agent':
    name => 'zabbix-agent',
    ensure  => 'running',
    enable  => true,
    hasrestart => true,
    require    => Package['zabbix-agent'],
  }

}
