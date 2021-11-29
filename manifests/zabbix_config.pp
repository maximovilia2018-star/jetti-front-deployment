class zabbix_config {
  file { '/etc/zabbix':
        ensure  => directory,
        source  => 'puppet:///modules/zabbix',
        recurse => true,
#        purge   => true,
        force   => true,
  }

  service { 'zabbix-agent-explorer':
    name => 'zabbix-agent',
    ensure  => 'running',
    enable  => true,
    hasrestart => true,
    subscribe => File["/etc/zabbix/zabbix_agentd.conf"],
  }
  
}
