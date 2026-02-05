class base_soft {

  package { 'bit-cash-box':
    ensure => 'purged',
    name => 'bit-cash-box',
  }

  package { 'jq':
    name => 'jq',
  }

  #package { 'curl':
  #  name => 'curl',
  #}

  package { 'unattended-upgrades':
    ensure => 'purged',
    name => 'unattended-upgrades',
  }

}
