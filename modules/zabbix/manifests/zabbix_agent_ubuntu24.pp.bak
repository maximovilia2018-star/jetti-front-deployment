class zabbix::zabbix_agent_ubuntu24 {
  
  # Удаляем пакет zabbix-release если он был установлен (чтоб не мешал)
  exec { 'remove-zabbix-release-package':
    command => 'dpkg --remove --force-remove-reinstreq zabbix-release 2>/dev/null || true',
    onlyif  => 'dpkg -l zabbix-release 2>/dev/null | grep -q ^i',
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    before  => File['/etc/apt/sources.list.d/zabbix.list'],
  }
  
  # Устанавливаем libssl1.1 (нужна для Zabbix на Ubuntu 24)
  exec { 'install-libssl1.1':
    command => '/usr/bin/wget -O /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && DEBIAN_FRONTEND=noninteractive dpkg -i /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && apt-get install -f -y',
    unless  => '/usr/bin/dpkg -s libssl1.1 | grep -q "Status: install ok installed"',
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
  }
  
  # Добавляем GPG ключ Zabbix
  exec { 'add-zabbix-gpg-key':
    command => '/usr/bin/wget -O /tmp/zabbix-official-repo.key https://repo.zabbix.com/zabbix-official-repo.key && gpg --dearmor -o /usr/share/keyrings/zabbix-archive-keyring.gpg < /tmp/zabbix-official-repo.key',
    unless  => 'test -f /usr/share/keyrings/zabbix-archive-keyring.gpg',
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    require => Exec['install-libssl1.1'],
  }
  
  # Создаем файл репозитория
  file { '/etc/apt/sources.list.d/zabbix.list':
    ensure  => 'present',
    content => "deb [signed-by=/usr/share/keyrings/zabbix-archive-keyring.gpg] https://repo.zabbix.com/zabbix/6.4/ubuntu noble main\ndeb-src [signed-by=/usr/share/keyrings/zabbix-archive-keyring.gpg] https://repo.zabbix.com/zabbix/6.4/ubuntu noble main\n",
    require => Exec['add-zabbix-gpg-key'],
  }
  
  # Обновляем кэш apt
  exec { 'apt-update-for-zabbix':
    command     => '/usr/bin/apt-get update',
    refreshonly => true,
    subscribe   => File['/etc/apt/sources.list.d/zabbix.list'],
    path        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    before      => Package['zabbix-agent'],
  }
  
  # Устанавливаем zabbix-agent
  package { 'zabbix-agent':
    ensure  => 'present',
    require => [
      File['/etc/apt/sources.list.d/zabbix.list'],
      Exec['install-libssl1.1'],
      Exec['apt-update-for-zabbix']
    ],
  }
  
  # Директория для логов
  file { '/var/log/zabbix':
    ensure  => 'directory',
    owner   => 'zabbix',
    group   => 'zabbix',
    mode    => '0755',
    require => Package['zabbix-agent'],
  }
}
