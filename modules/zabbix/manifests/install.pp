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
  exec { 'install_zabbix_repository':
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    command => "wget -q --tries=3 --timeout=30 -O /tmp/${repo_deb} ${repo_url} && dpkg -i --force-confmiss /tmp/${repo_deb} && apt-get update -qq",
    unless  => "dpkg -s zabbix-release >/dev/null 2>&1 && grep -q '/zabbix/${zabbix_version}/' /etc/apt/sources.list.d/zabbix.list 2>/dev/null",
    timeout => 300,
  }

  # Установка Zabbix Agent
  package { 'zabbix-agent':
    ensure  => present,
    require => Exec['install_zabbix_repository'],
  }

  # Директория для логов
  file { '/var/log/zabbix':
    ensure  => directory,
    owner   => 'zabbix',
    group   => 'zabbix',
    mode    => '0755',
    require => Package['zabbix-agent'],
  }

  # Очистка deb-пакета после установки
  exec { 'cleanup_zabbix_repo_deb':
    path        => ['/usr/bin', '/bin'],
    command     => "rm -f /tmp/${repo_deb}",
    refreshonly => true,
    subscribe   => Exec['install_zabbix_repository'],
  }

  # DAG
  Exec['install_zabbix_repository']
    -> Package['zabbix-agent']
    -> File['/var/log/zabbix']

  Exec['install_zabbix_repository']
    ~> Exec['cleanup_zabbix_repo_deb']
}
