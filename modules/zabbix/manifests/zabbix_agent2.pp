class zabbix::zabbix_agent2 {
  case $facts['os']['release']['major'] {
    /^(18|20)\.04$/: {
      # Ubuntu 18.04, 20.04 - Zabbix 5.4
      exec { 'install-zabbix-repository':
        command => '/usr/bin/wget -O /tmp/zabbix-release_5.4-1+debian10_all.deb https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian10_all.deb && dpkg -i /tmp/zabbix-release_5.4-1+debian10_all.deb && apt-get update',
        unless  => '/bin/dpkg -s zabbix-agent | grep -q "Version: "',
        path    => ['/usr/bin', '/bin'],
      }
      
      $repo_require = Exec['install-zabbix-repository']
      $deps_require = []
    }
    
    /^(22|24)\.04$/: {
      # Ubuntu 22.04, 24.04 - Zabbix 6.4
      
      # 1. ВКЛЮЧАЕМ UNIVERSE РЕПОЗИТОРИЙ
      exec { 'enable-universe-repo':
        command => '/usr/bin/add-apt-repository universe -y && apt-get update',
        unless  => '/usr/bin/apt-cache policy | grep -q "universe.*http"',
        path    => ['/usr/bin', '/bin'],
      }
      
      # 2. Устанавливаем libssl1.1 для 24.04
      if $facts['os']['release']['major'] == '24.04' {
        exec { 'install-libssl1.1':
          command => '/usr/bin/wget -O /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && dpkg -i /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb || apt-get install -f -y',
          unless  => '/usr/bin/dpkg -s libssl1.1 | grep -q "Status: install ok installed"',
          require => Exec['enable-universe-repo'],
          path    => ['/usr/bin', '/bin'],
        }
        $ssl_require = Exec['install-libssl1.1']
      } else {
        $ssl_require = []
      }
      
      # 3. Устанавливаем зависимости Zabbix
      package { ['libldap-2.5-0', 'libldap-common', 'libssl3']:
        ensure  => 'present',
        require => Exec['enable-universe-repo'],
        before  => Package['zabbix-agent'],
      }
      
      # 4. Удаляем старый репозиторий
      exec { 'clean-old-zabbix-repo':
        command => 'dpkg --remove --force-remove-reinstreq zabbix-release 2>/dev/null || true && rm -f /etc/apt/sources.list.d/zabbix.list',
        onlyif  => 'test -f /etc/apt/sources.list.d/zabbix.list || dpkg -l zabbix-release 2>/dev/null | grep -q ^i',
        path    => ['/usr/bin', '/bin'],
        require => [Exec['enable-universe-repo'], $ssl_require],
      }

      # 5. Устанавливаем репозиторий Zabbix
      exec { 'install-zabbix-repository-64':
        command => '/usr/bin/wget -O /tmp/zabbix-release_6.4-1+ubuntu22.04_all.deb https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb && dpkg -i /tmp/zabbix-release_6.4-1+ubuntu22.04_all.deb && apt-get update',
        unless  => '/bin/dpkg -s zabbix-agent | grep -q "Version: 6.4"',
        require => Exec['clean-old-zabbix-repo'],
        path    => ['/usr/bin', '/bin'],
      }
      
      $repo_require = Exec['install-zabbix-repository-64']
      $deps_require = [Package['libldap-2.5-0'], Package['libldap-common'], Package['libssl3']]
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

  # Установка Zabbix агента
  package { 'zabbix-agent':
    ensure  => 'present',
    require => [$repo_require, $deps_require].flatten(),
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
