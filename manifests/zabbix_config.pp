class zabbix_config {
  file { '/etc/zabbix':
        ensure  => directory,
        source  => 'puppet:///modules/zabbix',
        recurse => true,
#        purge   => true,
        force   => true,
  }
}
