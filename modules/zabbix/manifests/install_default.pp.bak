# modules/zabbix/manifests/install_default.pp
#
# Установка Zabbix Agent на Ubuntu 20.04/22.04.

class zabbix::install_default (
  String $zabbix_version,
){

  # Таблица соответствия версий Ubuntu → суффикс для deb-пакета
  $repo_suffix_map = {
    '20.04' => 'ubuntu20.04',
    '22.04' => 'ubuntu22.04',
  }

  $repo_suffix = $repo_suffix_map[$facts['os']['release']['major']] ? {
    undef   => "ubuntu${facts['os']['release']['major']}",
    default => $repo_suffix_map[$facts['os']['release']['major']],
  }

  $repo_deb = "zabbix-release_${zabbix_version}-1+${repo_suffix}_all.deb"
  $repo_url = "https://repo.zabbix.com/zabbix/${zabbix_version}/ubuntu/pool/main/z/zabbix-release/${repo_deb}"

  # Установка репозитория Zabbix
  exec { 'zabbix_repo_download':
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    command => "wget -q -O /tmp/${repo_deb} ${repo_url}",
    unless  => "test -f /tmp/${repo_deb} || dpkg-query -W -f='\${Status}' zabbix-release 2>/dev/null | grep -q 'install ok installed'",
    timeout => 120,
  }

  exec { 'zabbix_repo_install':
    path    => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
    command => "dpkg -i /tmp/${repo_deb}",
    unless  => "dpkg-query -W -f='\${Status}' zabbix-release 2>/dev/null | grep -q 'install ok installed'",
  }

  # Обновляем APT-кэш после установки репозитория
  exec { 'zabbix_apt_update':
    path        => ['/usr/bin', '/bin'],
    command     => 'apt-get update',
    refreshonly => true,
    subscribe   => Exec['zabbix_repo_install'],
    timeout     => 120,
  }

  # Установка Zabbix Agent
  package { 'zabbix-agent':
    ensure => present,
  }

  # Очистка deb-пакета репозитория (после установки)
  exec { 'zabbix_repo_cleanup':
    path    => ['/usr/bin', '/bin'],
    command => "rm -f /tmp/${repo_deb}",
    onlyif  => "test -f /tmp/${repo_deb}",
  }

  # Директория для логов
  file { '/var/log/zabbix':
    ensure => directory,
    owner  => 'zabbix',
    group  => 'zabbix',
    mode   => '0755',
  }

  # DAG
  Exec['zabbix_repo_download']
    -> Exec['zabbix_repo_install']
    -> Exec['zabbix_apt_update']
    -> Package['zabbix-agent']

  Exec['zabbix_repo_install']
    -> Exec['zabbix_repo_cleanup']

  Package['zabbix-agent']
    -> File['/var/log/zabbix']

}
