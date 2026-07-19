# modules/splunk_ua/manifests/install.pp
#
# Установка Splunk Universal Forwarder из корпоративного APT-репозитория.

class splunk_ua::install {

  package { 'splunkforwarder':
    ensure => installed,
  }

  exec { 'splunk_enable_boot':
    path    => ['/bin', '/usr/bin'],
    command => '/opt/splunkforwarder/bin/splunk enable boot-start -user splunk --accept-license --answer-yes --no-prompt',
    creates => '/etc/init.d/splunk',
    require => Package['splunkforwarder'],
  }

  service { 'splunk':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Exec['splunk_enable_boot'],
  }
}
