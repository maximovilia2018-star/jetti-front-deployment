class base_soft {
  package { 'unattended-upgrades':
    ensure => 'purged',
  }

  package { 'bit-cash-box':
    ensure => 'purged',
  }

  $required_tools = [ 'jq', 'curl', 'wget', 'mc', 'htop' ]

  package { $required_tools:
    ensure  => 'present',
    require => Package['unattended-upgrades'],
  }

}
