class zabbix::zabbix_agent2 {
  case $facts['os']['release']['major'] {
    /^(18|20)\.04$/: {
      # Ubuntu 18.04, 20.04 - Zabbix 5.4
      exec { 'install-zabbix-repository':
        command => '/usr/bin/wget -O /tmp/zabbix-release_5.4-1+debian10_all.deb https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian10_all.deb && dpkg -i /tmp/zabbix-release_5.4-1+debian10_all.deb && apt-get update',
        unless  => '/bin/dpkg -s zabbix-agent | grep -q "Version: "',
        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
      }
      
      $repo_require = 'Exec[install-zabbix-repository]'
      $deps_require = []
    }
    
    /^(22|24)\.04$/: {
      # Ubuntu 22.04, 24.04 - Zabbix 6.4
      
      # 1. Включаем universe репозиторий
      exec { 'enable-universe-repo':
        command => '/usr/bin/add-apt-repository universe -y && apt-get update',
        unless  => '/usr/bin/apt-cache policy | grep -q "universe.*http"',
        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
      }
      
      # 2. Добавляем архитектуру amd64 
      exec { 'add-amd64-architecture':
        command => '/usr/bin/dpkg --add-architecture amd64 && apt-get update',
        unless  => '/usr/bin/dpkg --print-foreign-architectures | grep -q amd64',
        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
        require => Exec['enable-universe-repo'],
      }
      
      # 3. Устанавливаем libssl1.1 для 24.04
      if $facts['os']['release']['major'] == '24.04' {
        exec { 'install-libssl1.1':
          command => '/usr/bin/wget -O /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && dpkg -i /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb || apt-get install -f -y',
          unless  => '/usr/bin/dpkg -s libssl1.1 | grep -q "Status: install ok installed"',
          require => [Exec['enable-universe-repo'], Exec['add-amd64-architecture']],
          path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
        }
        $ssl_require = Exec['install-libssl1.1']
        
        # Для Ubuntu 24.04
        package { 'libldap2':
          ensure  => 'present',
          require => Exec['enable-universe-repo'],
          before  => Package['zabbix-agent'],
        }
        
        package { 'libldap-common':
          ensure  => 'present',
          require => Exec['enable-universe-repo'],
          before  => Package['zabbix-agent'],
        }
        
        package { 'libssl3':
          ensure  => 'present',
          require => Exec['enable-universe-repo'],
          before  => Package['zabbix-agent'],
        }
        
        $deps_require = ['Package[libldap2]', 'Package[libldap-common]', 'Package[libssl3]']
      } else {
        $ssl_require = []
        # Для Ubuntu 22.04
        package { 'libldap-2.5-0':
          ensure  => 'present',
          require => Exec['enable-universe-repo'],
          before  => Package['zabbix-agent'],
        }
        
        package { 'libldap-common':
          ensure  => 'present',
          require => Exec['enable-universe-repo'],
          before  => Package['zabbix-agent'],
        }
        
        package { 'libssl3':
          ensure  => 'present',
          require => Exec['enable-universe-repo'],
          before  => Package['zabbix-agent'],
        }
        
        $deps_require = ['Package[libldap-2.5-0]', 'Package[libldap-common]', 'Package[libssl3]']
      }
      
      # 4. Удаляем старый репозиторий
      exec { 'clean-old-zabbix-repo':
        command => 'dpkg --remove --force-remove-reinstreq zabbix-release 2>/dev/null || true && rm -f /etc/apt/sources.list.d/zabbix.list',
        onlyif  => 'test -f /etc/apt/sources.list.d/zabbix.list || dpkg -l zabbix-release 2>/dev/null | grep -q ^i',
        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
        require => $facts['os']['release']['major'] ? {
          '24.04' => [Exec['enable-universe-repo'], Exec['add-amd64-architecture'], Exec['install-libssl1.1']],
          default => [Exec['enable-universe-repo'], Exec['add-amd64-architecture']],
        },
      }

      # 5. Устанавливаем репозиторий Zabbix
      exec { 'install-zabbix-repository-64':
        command => '/usr/bin/wget -O /tmp/zabbix-release_6.4-1+ubuntu22.04_all.deb https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb && dpkg -i /tmp/zabbix-release_6.4-1+ubuntu22.04_all.deb && apt-get update',
        unless  => '/bin/dpkg -s zabbix-agent | grep -q "Version: 6.4"',
        require => Exec['clean-old-zabbix-repo'],
        path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
      }
      
      # 6. Дополнительное обновление после добавления репозитория
      exec { 'apt-update-after-repo':
        command     => '/usr/bin/apt-get update',
        refreshonly => true,
        subscribe   => Exec['install-zabbix-repository-64'],
        before      => Package['zabbix-agent'],
        path        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
      }
      
      $repo_require = 'Exec[install-zabbix-repository-64]'
    }
    
    default: {
      notify { "zabbix-unsupported-os-${facts['os']['release']['major']}":
        message  => "Unsupported OS version: ${facts['os']['release']['major']}",
        loglevel => warning,
      }
      $repo_require = undef
      $deps_require = []
    }
  }

  # Установка Zabbix агента с явным указанием архитектуры
  package { 'zabbix-agent':
    ensure  => 'present',
    name    => 'zabbix-agent:amd64',  # Явно указываем архитектуру
    require => [$repo_require, $deps_require, Exec['apt-update-after-repo']].flatten(),
  }

  # Очистка
  exec { 'cleanup-zabbix-deb':
    command => 'rm -f /tmp/zabbix-release_*.deb /tmp/libssl1.1_*.deb',
    onlyif  => 'ls /tmp/zabbix-release_*.deb /tmp/libssl1.1_*.deb 2>/dev/null',
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
