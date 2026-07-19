# modules/zabbix/manifests/install.pp
#
# Установка Zabbix Agent

class zabbix::install (
  String $zabbix_version,
){
  # Определяем кодовое имя Ubuntu для репозитория
  case $facts['os']['release']['major'] {
    '20.04': {
      $ubuntu_codename = 'focal'
    }
    '22.04': {
      $ubuntu_codename = 'jammy'
    }
    default: {
      fail("Unsupported Ubuntu version ${facts['os']['release']['major']}. Only 20.04 and 22.04 are supported.")
    }
  }

  # Добавляем репозиторий Zabbix (всегда под управлением Puppet)
  file { '/etc/apt/sources.list.d/zabbix.list':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    #content => "deb [arch=amd64] https://repo.zabbix.com/zabbix/${zabbix_version}/ubuntu ${ubuntu_codename} main\n",
    content => "deb [arch=amd64 signed-by=/usr/share/keyrings/zabbix.gpg] https://repo.zabbix.com/zabbix/${zabbix_version}/ubuntu ${ubuntu_codename} main\n",
  }

  # Добавляем GPG ключ репозитория (всегда под управлением Puppet)
  file { '/usr/share/keyrings/zabbix.gpg':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/zabbix/zabbix-official-repo.gpg',
  }

  # Обновляем APT-кэш при изменении репозитория или ключа
  exec { 'zabbix_apt_update':
    path        => ['/usr/bin', '/bin'],
    command     => 'apt-get update -qq',
    refreshonly => true,
    timeout     => 300,
    logoutput   => on_failure,
  }

  # Установка Zabbix Agent
  package { 'zabbix-agent':
    ensure => present,
  }

  # Директория для логов
  file { '/var/log/zabbix':
    ensure => directory,
    owner  => 'zabbix',
    group  => 'zabbix',
    mode   => '0755',
  }

  # DAG - все зависимости в одном месте
  File['/usr/share/keyrings/zabbix.gpg']
    -> File['/etc/apt/sources.list.d/zabbix.list']
    ~> Exec['zabbix_apt_update']
    -> Package['zabbix-agent']
    -> File['/var/log/zabbix']
  
}
