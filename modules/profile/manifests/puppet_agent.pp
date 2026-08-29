# modules/profile/manifests/puppet_agent.pp
class profile::puppet_agent {
  # Изменяем интервал опроса сервера до 10 минут, чтобы снизить нагрузку
  exec { 'update_puppet_runinterval':
    command => '/bin/sed -i "/^\[agent\]/,/^\[/ s/^#\?\s*runinterval\s*=.*/runinterval = 10m/" /etc/puppetlabs/puppet/puppet.conf',
    # Запускаем sed только в том случае, если в конфиге ЕЩЕ НЕ стоит 10m
    unless  => '/bin/grep -E "^[^#]*runinterval\s*=\s*10m" /etc/puppetlabs/puppet/puppet.conf',
    notify  => Service['puppet'], # Перезапуск службы произойдет только при реальном изменении файла
  }

  service { 'puppet':
    ensure => running,
    enable => true,
  }
}
