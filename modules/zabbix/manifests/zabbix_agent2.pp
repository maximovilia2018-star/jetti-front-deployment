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
    
    if $ubuntu_version == '24.04' {
      # Для Ubuntu 24.04 используем специальный пакет, если он доступен
      $repo_version = '24.04'
      $release_pkg = "zabbix-release_6.4-1+ubuntu${repo_version}_all.deb"
      $release_url = "https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/${release_pkg}"
      
      # Проверяем доступность пакета для 24.04
      exec { 'check-zabbix-release-2404':
        command => '/bin/true',
        onlyif  => "/usr/bin/wget --spider ${release_url}",
        before  => Exec['install-zabbix-repository-64'],
      }
      
      # Если пакет для 24.04 не найден, используем пакет для 22.04
      $fallback_release_pkg = 'zabbix-release_6.4-1+ubuntu22.04_all.deb'
      $fallback_release_url = "https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/${fallback_release_pkg}"
      
      # Устанавливаем libssl1.1 для совместимости
      exec { 'install-libssl1.1':
        command => '/usr/bin/wget -O /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && dpkg -i /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb || apt-get install -f -y',
        unless  => '/usr/bin/dpkg -s libssl1.1 | grep -q "Status: install ok installed"',
      }
      
      # Пытаемся установить репозиторий, пробуем 24.04, если нет - 22.04
      exec { 'install-zabbix-repository-64':
        command => "/usr/bin/wget -O /tmp/zabbix-release_6.4-1+ubuntu24.04_all.deb ${release_url} || /usr/bin/wget -O /tmp/zabbix-release_6.4-1+ubuntu22.04_all.deb ${fallback_release_url} && dpkg -i /tmp/zabbix-release_6.4-1+ubuntu*.deb && apt update",
        unless  => "/bin/dpkg -s zabbix-agent | grep -q 'Version: 6.4'",
        require => Exec['install-libssl1.1'],
      }
    } else {
      # Ubuntu 22.04 - точное имя пакета
      $release_pkg = 'zabbix-release_6.4-1+ubuntu22.04_all.deb'
      
      exec { 'install-zabbix-repository-64':
        command => "/usr/bin/wget -O /tmp/${release_pkg} https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/${release_pkg} && dpkg -i /tmp/${release_pkg} && apt update",
        unless  => "/bin/dpkg -s zabbix-agent | grep -q 'Version: 6.4'",
      }
    }
  
    # Устанавливаем агент
    package { 'zabbix-agent':
      ensure  => '6.4.*',  # Установит последнюю версию 6.4.x
      require => Exec['install-zabbix-repository-64'],
    }
  
    # Очистка
    exec { 'remove-zabbix-release-deb':
      command => "rm -f /tmp/zabbix-release_6.4-1+ubuntu*.deb",
      onlyif  => "ls /tmp/zabbix-release_6.4-1+ubuntu*.deb 2>/dev/null",
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
