# modules/zabbix/manifests/install.pp
#
# Установка Zabbix Agent

class zabbix::install (
  String $zabbix_version,
){
  # Определяем версию Ubuntu для правильного deb-пакета
  case $facts['os']['release']['major'] {
    '20.04': {
      $ubuntu_repo = 'ubuntu20.04'
    }
    '22.04': {
      $ubuntu_repo = 'ubuntu22.04'
    }
    default: {
      fail("Unsupported Ubuntu version ${facts['os']['release']['major']}. Only 20.04 and 22.04 are supported.")
    }
  }

  $repo_deb = "zabbix-release_${zabbix_version}-1+${ubuntu_repo}_all.deb"
  $repo_url = "https://repo.zabbix.com/zabbix/${zabbix_version}/ubuntu/pool/main/z/zabbix-release/${repo_deb}"

  # Установка репозитория Zabbix (только если агент не установлен)
  exec { 'zabbix_repo_download':
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    command => "curl -fsSL -o /tmp/${repo_deb} ${repo_url}",
    unless  => "/usr/bin/dpkg-query -W zabbix-agent >/dev/null 2>&1",
    timeout => 120,
  }

  exec { 'zabbix_repo_install':
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    command => "dpkg -i /tmp/${repo_deb}",
    unless  => "/usr/bin/dpkg-query -W zabbix-agent >/dev/null 2>&1",
  }

  # Обновляем APT-кэш после установки репозитория
  exec { 'zabbix_apt_update':
    path        => ['/usr/bin', '/bin'],
    command     => 'apt-get update',
    refreshonly => true,
    timeout     => 120,
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

  # Очистка deb-пакета репозитория (после установки агента)
  exec { 'zabbix_repo_cleanup':
    path        => ['/usr/bin', '/bin'],
    command     => "rm -f /tmp/${repo_deb}",
    refreshonly => true,
    subscribe   => Package['zabbix-agent'],
  }
  
  # DAG
  Exec['zabbix_repo_download']
    -> Exec['zabbix_repo_install']
    ~> Exec['zabbix_apt_update']
    -> Package['zabbix-agent']
    -> File['/var/log/zabbix']
}
