# modules/zabbix/manifests/install_ubuntu24.pp
#
# Установка Zabbix Agent на Ubuntu 24.04.

class zabbix::install_ubuntu24 (
  String $zabbix_version,
){

  # Установка libssl1.1 (необходимо для Zabbix 6.4 на Ubuntu 24)
  exec { 'zabbix_install_libssl':
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    command => 'wget -q -O /tmp/libssl1.1.deb http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb && dpkg -i /tmp/libssl1.1.deb && apt-get install -f -y',
    unless  => "dpkg -s libssl1.1 2>/dev/null | grep -q 'Status: install ok installed'",
    timeout => 120,
  }

  # Добавление GPG ключа Zabbix
  exec { 'zabbix_add_gpg_key':
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    command => 'wget -q -O /tmp/zabbix-official-repo.key https://repo.zabbix.com/zabbix-official-repo.key && gpg --dearmor -o /usr/share/keyrings/zabbix-archive-keyring.gpg < /tmp/zabbix-official->
    creates => '/usr/share/keyrings/zabbix-archive-keyring.gpg',
  }

  # Добавление репозитория Zabbix
  file { '/etc/apt/sources.list.d/zabbix.list':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => @("EOF")
deb [signed-by=/usr/share/keyrings/zabbix-archive-keyring.gpg] https://repo.zabbix.com/zabbix/${zabbix_version}/ubuntu noble main
deb-src [signed-by=/usr/share/keyrings/zabbix-archive-keyring.gpg] https://repo.zabbix.com/zabbix/${zabbix_version}/ubuntu noble main
| EOF
  }

  # Обновляем APT-кэш после создания файла репозитория
  exec { 'zabbix_apt_update':
    path        => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    command     => 'apt-get update',
    refreshonly => true,
    subscribe   => File['/etc/apt/sources.list.d/zabbix.list'],
    timeout     => 120,
  }

  # Установка Zabbix Agent
  package { 'zabbix-agent':
    ensure => present,
  }

  # Очистка временных файлов (после установки пакета)
  exec { 'zabbix_cleanup_libssl':
    path    => ['/usr/bin', '/bin'],
    command => 'rm -f /tmp/libssl1.1.deb',
    onlyif  => 'test -f /tmp/libssl1.1.deb',
  }

  # Директория для логов
  file { '/var/log/zabbix':
    ensure => directory,
    owner  => 'zabbix',
    group  => 'zabbix',
    mode   => '0755',
  }

  # DAG
  Exec['zabbix_install_libssl']
    -> Exec['zabbix_add_gpg_key']
    -> File['/etc/apt/sources.list.d/zabbix.list']
    -> Exec['zabbix_apt_update']
    -> Package['zabbix-agent']

  # Очистка временного файла после установки пакета
  Package['zabbix-agent']
    -> Exec['zabbix_cleanup_libssl']

  Package['zabbix-agent']
    -> File['/var/log/zabbix']

}
