#modules/profile_base/manifests/journald.pp
# Изменения journald.conf вступают в силу после перезагрузки.
# не выполняем restart systemd-journald во время работы кассы.
class profile_base::journald {
  file_line { 'journald_systemmaxuse':
    path               => '/etc/systemd/journald.conf',
    match              => '^\s*#?\s*SystemMaxUse=',
    line               => 'SystemMaxUse=100M',
    append_on_no_match => true,
  }

  file_line { 'journald_systemkeepfree':
    path               => '/etc/systemd/journald.conf',
    match              => '^\s*#?\s*SystemKeepFree=',
    line               => 'SystemKeepFree=500M',
    append_on_no_match => true,
  }

  file_line { 'journald_maxretention':
    path               => '/etc/systemd/journald.conf',
    match              => '^\s*#?\s*MaxRetentionSec=',
    line               => 'MaxRetentionSec=7d',
    append_on_no_match => true,
  }

  cron { 'journald-vacuum':
    ensure  => present,
    user    => 'root',
    minute  => '34',
    hour    => '12',
    command => '/usr/bin/journalctl --vacuum-time=7d --quiet',
  }
}
