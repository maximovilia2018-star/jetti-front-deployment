class zabbix::zabbix_agent2 {
  case $facts['os']['release']['major'] {
    /^(18|20)\.04$/: {
      # Ubuntu 18.04, 20.04 - Zabbix 5.4
      exec { "install-zabbix-repository":
        command => "/usr/bin/wget https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian10_all.deb && dpkg -i zabbix-release_5.4-1+debian10_all.deb && apt update",
        unless  => "/bin/dpkg -s zabbix-agent | grep -q 'Version: '",
      }
    }
    
    /^(22|24)\.04$/: {
      # Ubuntu 22.04, 24.04 - Zabbix 6.4
      
      # Для 24.04 нужен libssl1.1
      if $facts['os']['release']['major'] == '24.04' {
        exec { 'install-libssl1.1':
          command => '/usr/bin/wget -O /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && dpkg -i /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb || apt-get install -f -y',
          unless  => '/usr/bin/dpkg -s libssl1.1 | grep -q "Status: install ok installed"',
        }
      }

      # Устанавливаем репозиторий Zabbix 6.4 (используем 22.04 пакет для 24.04)
      exec { 'install-zabbix-repository-64':
        command => "/usr/bin/wget -O /tmp/zabbix-release_6.4-1+ubuntu22.04_all.deb https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb && dpkg -i /tmp/zabbix-release_6.4-1+ubuntu22.04_all.deb && apt update",
        unless  => "/bin/dpkg -s zabbix-agent | grep -q 'Version: 6.4'",
        require => $facts['os']['release']['major'] ? {
          '24.04' => Exec['install-libssl1.1'],
          default => [],
        },
      }
    }
    
    default: {
      notify { "zabbix-unsupported-os-${facts['os']['release']['major']}":
        message  => "Unsupported OS version: ${facts['os']['release']['major']}",
        loglevel => warning,
      }
    }
  }

  # ЕДИНАЯ УСТАНОВКА ДЛЯ ВСЕХ - просто пакет без версии!
  package { 'zabbix-agent':
    ensure  => 'present',
    require => $facts['os']['release']['major'] ? {
      /^(18|20)\.04$/ => Exec['install-zabbix-repository'],
      /^(22|24)\.04$/ => Exec['install-zabbix-repository-64'],
      default         => undef,
    },
  }

  # Очистка временных файлов
  exec { 'cleanup-zabbix-deb':
    command => 'rm -f /tmp/zabbix-release_*',
    onlyif  => 'ls /tmp/zabbix-release_* 2>/dev/null',
    path    => ['/bin', '/usr/bin'],
    require => Package['zabbix-agent'],
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
