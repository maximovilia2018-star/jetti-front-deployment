class zabbix::remove_zabbix {
  # Останавливаем сервис перед удалением
  service { 'zabbix-agent':
    ensure => 'stopped',
    enable => false,
    before => Package['zabbix-agent'],
  }

  # Удаляем пакет и конфиги
  package { 'zabbix-agent':
    ensure   => 'purged',
    provider => 'apt',
  }

  # Удаляем репозиторий
  exec { 'remove-zabbix-repository':
    command => '/usr/bin/rm -f /etc/apt/sources.list.d/zabbix.list',
    onlyif  => '/usr/bin/test -f /etc/apt/sources.list.d/zabbix.list',
    require => Package['zabbix-agent'],
  }

  # Удаляем GPG ключ
  exec { 'remove-zabbix-gpg-key':
    command => '/usr/bin/rm -f /etc/apt/trusted.gpg.d/zabbix*.gpg* /usr/share/keyrings/zabbix*.gpg 2>/dev/null || true',
    onlyif  => 'ls /etc/apt/trusted.gpg.d/zabbix*.gpg* /usr/share/keyrings/zabbix*.gpg 2>/dev/null | grep -q .',
    require => Package['zabbix-agent'],
  }

  # Удаляем директории логов
  file { '/var/log/zabbix':
    ensure  => 'absent',
    force   => true,
    recurse => true,
    require => Package['zabbix-agent'],
  }

  # ОБНОВЛЯЕМ APT после удаления репозитория
  exec { 'apt-update-after-removal':
    command     => '/usr/bin/apt-get update',
    refreshonly => true,
    subscribe   => [Exec['remove-zabbix-repository'], Exec['remove-zabbix-gpg-key']],
  }
}
