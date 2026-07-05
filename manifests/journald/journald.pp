class journald {

  service { 'systemd-journald':
    ensure => running,
    enable => true,
  }

  file_line { 'journald_systemmaxuse':
    path               => '/etc/systemd/journald.conf',
    match              => '^\s*#?\s*SystemMaxUse=',
    line               => 'SystemMaxUse=100M',
    append_on_no_match => true,
    notify             => Service['systemd-journald'],
  }

  file_line { 'journald_systemkeepfree':
    path               => '/etc/systemd/journald.conf',
    match              => '^\s*#?\s*SystemKeepFree=',
    line               => 'SystemKeepFree=500M',
    append_on_no_match => true,
    notify             => Service['systemd-journald'],
  }

  file_line { 'journald_maxretention':
    path               => '/etc/systemd/journald.conf',
    match              => '^\s*#?\s*MaxRetentionSec=',
    line               => 'MaxRetentionSec=604800',
    append_on_no_match => true,
    notify             => Service['systemd-journald'],
  }

  cron { 'journald-vacuum':
    ensure  => present,
    user    => 'root',
    minute  => '34',
    hour    => '12',
    command => '/usr/bin/journalctl --vacuum-time=7d --quiet',
    require => Service['systemd-journald'],
  }
}
