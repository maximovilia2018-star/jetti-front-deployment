# modules/zabbix/manifests/config.pp
#
# Настройка Zabbix Agent.

class zabbix::config (
#  String $zbx_srv = $zabbix::zbx_srv,
  String $zbx_srv,
) {
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
    mode    => '0644',
    require => File['/etc/zabbix'],
    notify  => Service['zabbix-agent'],
  }

  # PSK-ключ для TLS шифрования
  file { '/etc/zabbix/zabbix_x100.psk':
    ensure  => file,
    owner   => 'zabbix',
    group   => 'zabbix',
    mode    => '0600',
    source => 'puppet:///modules/zabbix/zabbix_x100.psk',
    require => File['/etc/zabbix'],
    notify  => Service['zabbix-agent'],
  }

  # Основной конфигурационный файл
  file { '/etc/zabbix/zabbix_agentd.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/zabbix'],
    notify  => Service['zabbix-agent'],
    content => epp(
      'zabbix/zabbix_agentd.conf.epp',
      {
        'zbx_srv'  => $zbx_srv,
        'hostname' => $facts['networking']['hostname'],
      }
    ),
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
