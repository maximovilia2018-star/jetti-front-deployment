class fiscal_ua(
    $versioncheckbox,
) {
  package { 'checkbox-kasa':
    ensure => "$versioncheckbox",
    name => 'checkbox-kasa',
  }

  file { '/usr/share/checkbox_kasa':
      ensure  => 'present',
      replace => 'no',
      owner => 'bit',
      group => 'bit',
      mode => '0644',
      require => Package['checkbox-kasa'],
  }
