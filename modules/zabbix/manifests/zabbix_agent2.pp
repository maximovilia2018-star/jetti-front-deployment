class zabbix::zabbix_agent2 {
  # Разделяем логику по версиям ОС
  case $facts['os']['release']['major'] {
    /^(18|20)\.04$/: {
      # Ubuntu 18.04, 20.04 - оставляем как есть, ничего не меняем
      exec { "install-zabbix-repository":
        command => "/usr/bin/wget https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian10_all.deb && dpkg -i zabbix-release_5.4-1+debian10_all.deb && apt update",
        user    => 'root',
        unless  => "/bin/dpkg -s zabbix-agent | grep -q 'Version: '",
      }

      package { 'zabbix-agent':
        name => 'zabbix-agent',
      }

      exec { 'remove zabbix-release.deb':
        path    => [ '/usr/bin', '/bin' ],
        command => "rm -f zabbix-release_5.4-1+debian10_all.*",
        onlyif  => "ls zabbix-release_5.4-1+debian10_all.* 2>/dev/null",
      }
    }
    
    /^(22|24)\.04$/: {
      # Ubuntu 22.04, 24.04 - устанавливаем Zabbix 6.4
      # Тут определяем правильный пакет для каждой версии
      if $facts['os']['release']['major'] == '24.04' {
        $release_pkg = 'zabbix-release_6.4-1+ubuntu24.04_all.deb'
        
        # Для 24.04 может понадобиться libssl1.1
        exec { 'install-libssl1.1':
          command => '/usr/bin/wget -O /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && dpkg -i /tmp/libssl1.1_1.1.1f-1ubuntu2_amd64.deb || apt-get install -f -y',
          unless  => '/usr/bin/dpkg -s libssl1.1 | grep -q "Status: install ok installed"',
          before  => Exec['install-zabbix-repository-64'],
        }
      } else {
        $release_pkg = 'zabbix-release_6.4-1+ubuntu22.04_all.deb'
      }

      exec { 'install-zabbix-repository-64':
        command => "/usr/bin/wget -O /tmp/${release_pkg} https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/${release_pkg} && dpkg -i /tmp/${release_pkg} && apt update",
        unless  => "/bin/dpkg -s zabbix-agent | grep -q 'Version: 6.4'",
      }

      package { 'zabbix-agent':
        ensure  => '6.4.4',  # Фиксируем версию для совместимости
        require => Exec['install-zabbix-repository-64'],
      }

      exec { 'remove zabbix-release-64.deb':
        path    => ['/usr/bin', '/bin'],
        command => "rm -f /tmp/${release_pkg}",
        onlyif  => "test -f /tmp/${release_pkg}",
      }
    }
    
    default: {
      # Для остальных версий - ничего не делаем или логируем ошибку
      notify { "zabbix-unsupported-os":
        message  => "Unsupported OS version: ${facts['os']['release']['major']}",
        loglevel => warning,
      }
    }
  }

  # Общие ресурсы для всех версий
  # Пользователь zabbix создается при установке пакета
  file { '/var/log/zabbix':
    ensure  => 'directory',
    owner   => 'zabbix',
    group   => 'zabbix',
    mode    => '0755',
    require => Package['zabbix-agent'],
  }
}
