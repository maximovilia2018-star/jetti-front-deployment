class zabbix::zabbix_agent2 {
  case $facts['os']['release']['major'] {
    /^(18|20)\.04$/: {
      # Ubuntu 18.04, 20.04 - Zabbix 5.4
      exec { 'install-zabbix-repository':
        command => '/usr/bin/wget -O /tmp/zabbix-release_5.4-1+ubuntu18.04_all.deb https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu18.04_all.deb && DEBIAN_FRONTEND=noninteractive dpkg -i --force-confdef --force-confold /tmp/zabbix-release_5.4-1+ubuntu18.04_all.deb && apt-get update',
        unless  => '/bin/dpkg -s zabbix-agent | grep -q "Version: 5.4"',
        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
        environment => ['DEBIAN_FRONTEND=noninteractive'],
      }
      
      package { 'zabbix-agent':
        ensure  => 'present',
        require => Exec['install-zabbix-repository'],
      }
    }
    
    /^22\.04$/: {
      # Ubuntu 22.04 - Zabbix 6.4
      exec { 'install-zabbix-repository':
        command => '/usr/bin/wget -O /tmp/zabbix-release_6.4-1+ubuntu22.04_all.deb https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb && DEBIAN_FRONTEND=noninteractive dpkg -i --force-confdef --force-confold /tmp/zabbix-release_6.4-1+ubuntu22.04_all.deb && apt-get update',
        unless  => '/bin/dpkg -s zabbix-agent | grep -q "Version: 6.4"',
        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
        environment => ['DEBIAN_FRONTEND=noninteractive'],
      }
      
      package { 'zabbix-agent':
        ensure  => 'present',
        require => Exec['install-zabbix-repository'],
      }
    }
    
    /^24\.04$/: {
      # Ubuntu 24.04 - Zabbix 6.4
      
      # 1. Удаляем старый репозиторий
      exec { 'remove-old-zabbix-repo':
        command => 'dpkg --remove --force-remove-reinstreq zabbix-release 2>/dev/null || true && rm -f /etc/apt/sources.list.d/zabbix.list',
        onlyif  => 'dpkg -l zabbix-release 2>/dev/null | grep -q ^i || test -f /etc/apt/sources.list.d/zabbix.list',
        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
      }
      
      # 2. Устанавливаем libssl1.1
      exec { 'install-libssl1.1':
        command => '/usr/bin/wget -O /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && DEBIAN_FRONTEND=noninteractive dpkg -i --force-confdef --force-confold /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb || apt-get install -f -y',
        unless  => '/usr/bin/dpkg -s libssl1.1 | grep -q "Status: install ok installed"',
        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
        environment => ['DEBIAN_FRONTEND=noninteractive'],
        require => Exec['remove-old-zabbix-repo'],
      }
      
      # 3. Добавляем GPG ключ Zabbix (КРИТИЧЕСКИ ВАЖНО!)
      exec { 'add-zabbix-gpg-key':
        command => '/usr/bin/wget -O /tmp/zabbix-official-repo.key https://repo.zabbix.com/zabbix-official-repo.key && gpg --dearmor -o /usr/share/keyrings/zabbix-archive-keyring.gpg < /tmp/zabbix-official-repo.key',
        unless  => 'test -f /usr/share/keyrings/zabbix-archive-keyring.gpg',
        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
        require => Exec['install-libssl1.1'],
      }
      
      # 4. СОЗДАЕМ ФАЙЛ РЕПОЗИТОРИЯ С УКАЗАНИЕМ КЛЮЧА
      file { '/etc/apt/sources.list.d/zabbix.list':
        ensure  => 'present',
        content => "deb [signed-by=/usr/share/keyrings/zabbix-archive-keyring.gpg] https://repo.zabbix.com/zabbix/6.4/ubuntu noble main\ndeb-src [signed-by=/usr/share/keyrings/zabbix-archive-keyring.gpg] https://repo.zabbix.com/zabbix/6.4/ubuntu noble main\n",
        require => Exec['add-zabbix-gpg-key'],
      }
      
      # 5. Обновляем пакеты
      exec { 'apt-update-for-zabbix':
        command     => '/usr/bin/apt-get update',
        refreshonly => true,
        subscribe   => File['/etc/apt/sources.list.d/zabbix.list'],
        path        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
        before      => Package['zabbix-agent'],
      }
      
      # 6. Устанавливаем Zabbix agent
      package { 'zabbix-agent':
        ensure  => 'present',
        require => [
          File['/etc/apt/sources.list.d/zabbix.list'],
          Exec['install-libssl1.1'],
          Exec['apt-update-for-zabbix']
        ],
      }
    }
    
    default: {
      notify { "zabbix-unsupported-os-${facts['os']['release']['major']}":
        message  => "Unsupported OS version: ${facts['os']['release']['major']}",
        loglevel => warning,
      }
    }
  }

  # Общие ресурсы
  file { '/var/log/zabbix':
    ensure  => 'directory',
    owner   => 'zabbix',
    group   => 'zabbix',
    mode    => '0755',
    require => Package['zabbix-agent'],
  }

  # Очистка
  exec { 'cleanup-zabbix-deb':
    command => 'rm -f /tmp/libssl1.1_*.deb /tmp/zabbix-official-repo.key',
    onlyif  => 'ls /tmp/libssl1.1_*.deb /tmp/zabbix-official-repo.key 2>/dev/null',
    path    => ['/bin', '/usr/bin'],
    require => Package['zabbix-agent'],
  }
}
