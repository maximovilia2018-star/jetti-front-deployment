class zabbix::zabbix_agent2 {
  case $facts['os']['release']['major'] {
    /^(18|20)\.04$/: {
      # Ubuntu 18.04, 20.04 - Zabbix 5.4
      exec { "install-zabbix-repository":
        command => "/usr/bin/wget https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu${facts['os']['release']['major']}.04_all.deb && dpkg -i zabbix-release_5.4-1+ubuntu${facts['os']['release']['major']}.04_all.deb && apt update",
        unless  => "/bin/dpkg -s zabbix-agent | grep -q 'Version: '",
      }

      package { 'zabbix-agent':
        ensure => 'present',
        require => Exec['install-zabbix-repository'],
      }
    }
    
    /^(22|24)\.04$/: {
      # Ubuntu 22.04, 24.04 - Zabbix 6.4
      $ubuntu_version = $facts['os']['release']['major']
      
      # Для 24.04 используем репозиторий 22.04, если 24.04 еще не готов
      if $ubuntu_version == '24.04' {
        $repo_version = '22.04'
        
        # Устанавливаем libssl1.1 для совместимости
        exec { 'install-libssl1.1':
          command => '/usr/bin/wget -O /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && dpkg -i /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb || apt-get install -f -y',
          unless  => '/usr/bin/dpkg -s libssl1.1 | grep -q "Status: install ok installed"',
        }
      } else {
        $repo_version = $ubuntu_version
      }

      exec { 'install-zabbix-repository-64':
        command => "/usr/bin/wget -O /tmp/zabbix-release_6.4-1+ubuntu${repo_version}.04_all.deb https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu${repo_version}.04_all.deb && dpkg -i /tmp/zabbix-release_6.4-1+ubuntu${repo_version}.04_all.deb && apt update",
        unless  => "/bin/dpkg -s zabbix-agent | grep -q 'Version: 6.4'",
        require => $ubuntu_version ? {
          '24.04' => Exec['install-libssl1.1'],
          default => [],
        },
      }

      # Устанавливаем последнюю доступную версию 6.4
      package { 'zabbix-agent':
        ensure  => '6.4.*',  # Установит последнюю 6.4.x
        require => Exec['install-zabbix-repository-64'],
      }

      exec { 'remove-zabbix-release-deb':
        command => "rm -f /tmp/zabbix-release_6.4-1+ubuntu${repo_version}.04_all.deb",
        onlyif  => "test -f /tmp/zabbix-release_6.4-1+ubuntu${repo_version}.04_all.deb",
        path    => ['/bin', '/usr/bin'],
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
}
