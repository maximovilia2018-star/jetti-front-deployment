class fiscal_ua {
  package { 'checkbox-kasa':
    ensure => "1.1.35",
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

}
