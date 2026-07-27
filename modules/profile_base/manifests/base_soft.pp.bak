# modules/profile_base/manifests/base_soft.pp
class profile_base::base_soft {
  package { ['unattended-upgrades', 'bit-cash-box', 'lubuntu-update-notifier']:
    ensure  => purged,
  }

  # Базовый набор утилит для POS 
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
