# modules/profile/manifests/puppet_agent.pp
class profile::puppet_agent {

  # Изменяем интервал опроса сервера до 10 минут, чтобы снизить нагрузку
  puppet_config { 'agent/runinterval':
    ensure => present,
    value  => '10m',
    notify => Service['puppet'], # Перезапустит службу для применения настроек
  }

  # Описываем службу, чтобы Puppet знал, что именно перезапускать
  service { 'puppet':
    ensure => running,
    enable => true,
  }
}
