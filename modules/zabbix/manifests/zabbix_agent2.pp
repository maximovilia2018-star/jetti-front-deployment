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
      # Ubuntu 24.04 - Zabbix 6.4 (официальный репозиторий!)
      
      # Сначала полностью удаляем старый репозиторий если есть
      exec { 'remove-old-zabbix-repo':
        command => 'dpkg --remove --force-remove-reinstreq zabbix-release 2>/dev/null || true && rm -f /etc/apt/sources.list.d/zabbix.list',
        onlyif  => 'dpkg -l zabbix-release 2>/dev/null | grep -q ^i || test -f /etc/apt/sources.list.d/zabbix.list',
        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
      }
      
      # Устанавливаем репозиторий с флагами noninteractive
      exec { 'install-zabbix-repository':
        command => '/usr/bin/wget -O /tmp/zabbix-release_6.4-1+ubuntu24.04_all.deb https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu24.04_all.deb && DEBIAN_FRONTEND=noninteractive dpkg -i --force-confdef --force-confold /tmp/zabbix-release_6.4-1+ubuntu24.04_all.deb && apt-get update',
        unless  => '/bin/dpkg -s zabbix-agent | grep -q "Version: 6.4"',
        require => Exec['remove-old-zabbix-repo'],
        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
        environment => ['DEBIAN_FRONTEND=noninteractive'],
      }
      
      # Zabbix 6.4 на Ubuntu 24.04 требует libssl1.1
      exec { 'install-libssl1.1':
        command => '/usr/bin/wget -O /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && DEBIAN_FRONTEND=noninteractive dpkg -i --force-confdef --force-confold /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb || apt-get install -f -y',
        unless  => '/usr/bin/dpkg -s libssl1.1 | grep -q "Status: install ok installed"',
        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
        environment => ['DEBIAN_FRONTEND=noninteractive'],
        before  => Package['zabbix-agent'],
      }
      
      package { 'zabbix-agent':
        ensure  => 'present',
        require => [
          Exec['install-zabbix-repository'],
          Exec['install-libssl1.1']
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

  # Общие ресурсы для всех версий
  file { '/var/log/zabbix':
    ensure  => 'directory',
    owner   => 'zabbix',
    group   => 'zabbix',
    mode    => '0755',
    require => Package['zabbix-agent'],
  }

  # Очистка временных файлов
  exec { 'cleanup-zabbix-deb':
    command => 'rm -f /tmp/zabbix-release_*.deb /tmp/libssl1.1_*.deb',
    onlyif  => 'ls /tmp/zabbix-release_*.deb /tmp/libssl1.1_*.deb 2>/dev/null',
    path    => ['/bin', '/usr/bin'],
    require => Package['zabbix-agent'],
  }
}
