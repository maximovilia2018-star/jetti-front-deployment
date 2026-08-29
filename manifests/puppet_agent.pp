class puppet_agent {
  # Изменяем интервал опроса сервера до 15 минут, чтобы снизить нагрузку
  puppet_config { 'agent/runinterval':
    ensure => present,
    value  => '15m',
    notify => Service['puppet'],
  }

  service { 'puppet':
    ensure => running,
    enable => true,
  }
}
