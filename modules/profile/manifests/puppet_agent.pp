# modules/profile/manifests/puppet_agent.pp
class profile::puppet_agent {

  # Изменяем интервал опроса сервера до 15 минут, чтобы снизить нагрузку
  puppet_config { 'agent/runinterval':
    ensure => present,
    value  => '15m',
    notify => Service['puppet'], # Перезапустит службу для применения настроек
  }

  # Описываем службу, чтобы Puppet знал, что именно перезапускать
  service { 'puppet':
    ensure => running,
    enable => true,
  }
}
