class puppet_agent {
  # Изменяем интервал опроса сервера до 15 минут, чтобы снизить нагрузку
  exec { 'update_puppet_runinterval':
    command => '/bin/sed -i "/^\[agent\]/,/^\[/ s/^#\?\s*runinterval\s*=.*/runinterval = 15m/" /etc/puppetlabs/puppet/puppet.conf',
    unless  => '/bin/grep -E "^[^#]*runinterval\s*=\s*15m" /etc/puppetlabs/puppet/puppet.conf',
    notify  => Service['puppet'],
  }

  service { 'puppet':
    ensure => running,
    enable => true,
  }
}
