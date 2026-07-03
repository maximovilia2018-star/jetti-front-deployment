class base_soft {
  package { [ 'unattended-upgrades', 'bit-cash-box', ]:
    ensure => purged,
  }

  $required_tools = [
    'ca-certificates',
    'curl',
    'gnupg',
    'htop',
    'jq',
    'mc',
    'wget',
  ]

  package { $required_tools:
    ensure  => present,
    require => Package['unattended-upgrades'],
  }
}
