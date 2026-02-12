class zabbix::zabbix_agent2 {
  case $facts['os']['release']['major'] {
    /^(18|20)\.04$/: {
      # Ubuntu 18.04, 20.04 - Zabbix 5.4
      exec { 'install-zabbix-repository':
        command => '/usr/bin/wget -O /tmp/zabbix-release_5.4-1+ubuntu18.04_all.deb https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu18.04_all.deb && dpkg -i /tmp/zabbix-release_5.4-1+ubuntu18.04_all.deb && apt-get update',
        unless  => '/bin/dpkg -s zabbix-agent | grep -q "Version: 5.4"',
        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
      }
      
      package { 'zabbix-agent':
        ensure  => 'present',
        require => Exec['install-zabbix-repository'],
      }
    }
    
    /^22\.04$/: {
      # Ubuntu 22.04 - Zabbix 6.4
      exec { 'install-zabbix-repository':
        command => '/usr/bin/wget -O /tmp/zabbix-release_6.4-1+ubuntu22.04_all.deb https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb && dpkg -i /tmp/zabbix-release_6.4-1+ubuntu22.04_all.deb && apt-get update',
        unless  => '/bin/dpkg -s zabbix-agent | grep -q "Version: 6.4"',
        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
      }
      
      package { 'zabbix-agent':
        ensure  => 'present',
        require => Exec['install-zabbix-repository'],
      }
    }
    
    /^24\.04$/: {
      # Ubuntu 24.04 - Zabbix 6.4 (официальный репозиторий!)
      exec { 'install-zabbix-repository':
        command => '/usr/bin/wget -O /tmp/zabbix-release_6.4-1+ubuntu24.04_all.deb https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu24.04_all.deb && dpkg -i /tmp/zabbix-release_6.4-1+ubuntu24.04_all.deb && apt-get update',
        unless  => '/bin/dpkg -s zabbix-agent | grep -q "Version: 6.4"',
        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
      }
      
      # Zabbix 6.4 на Ubuntu 24.04 требует libssl1.1
      exec { 'install-libssl1.1':
        command => '/usr/bin/wget -O /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && dpkg -i /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb || apt-get install -f -y',
        unless  => '/usr/bin/dpkg -s libssl1.1 | grep -q "Status: install ok installed"',
        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
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
