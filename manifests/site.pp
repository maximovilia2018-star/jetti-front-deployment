node 'default' {
  include jetti_front
  include zabbix_agent
  include base_soft
  include splunk
  $version = '1.3.70'
  $versionsp = '0.1.6'
  $githubtoken = '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'

  file { "/etc/environment":
    ensure  => 'present',
    replace => 'yes',
    content => "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\"
ENV=\"${environment}\"
INSTRUMENTATION_KEY=35fd1bc1-4335-4fea-982c-de47128ca595",
    }

  exec { "jetti-front":
    command => "/usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold --force-yes install jetti-front=$version",
    user    => 'root',
    unless  => ["/bin/dpkg -s jetti-front | grep \'Version: $version\'", "/bin/bash /opt/precheck_before_update.sh ${version}"],
  }

  package { 'jetti-front':
    ensure => "$version",
    name => 'jetti-front',
    noop => true,
  }

}

node /(?i)^ua-mp-*/{
  $ua_mp = '1.3.71'

  exec { "jetti-front":
    command => "/usr/bin/dpkg --configure -a && /usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold --force-yes install jetti-front=$ua_mp && reboot" ,
    user    => 'root',
    unless  => ["/bin/dpkg -s jetti-front | grep \'Version: $ua_mp\'", "/bin/bash /opt/precheck_before_update.sh ${ua_mp}"],
  }

  package { 'jetti-front':
    ensure => "$ua_mp",
    name => 'jetti-front',
    noop => true,
  }
}

node /(?i)^ua-sm-*/{
  $ua_sm = '1.3.72'

  exec { "jetti-front":
    command => "/usr/bin/dpkg --configure -a && /usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold --force-yes install jetti-front=$ua_sm && reboot" ,
    user    => 'root',
    unless  => ["/bin/dpkg -s jetti-front | grep \'Version: $ua_sm\'", "/bin/bash /opt/precheck_before_update.sh ${ua_sm}"],
  }

  package { 'jetti-front':
    ensure => "$ua_sm",
    name => 'jetti-front',
    noop => true,
  }
}

node /(?i)^ru-gs-*/{
  $ru_gs = '1.3.73'

  exec { "jetti-front":
    command => "/usr/bin/dpkg --configure -a && /usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold --force-yes install jetti-front=$ru_gs && reboot" ,
    user    => 'root',
    unless  => ["/bin/dpkg -s jetti-front | grep \'Version: $ru_gs\'", "/bin/bash /opt/precheck_before_update.sh ${ru_gs}"],
  }

  package { 'jetti-front':
    ensure => "$ru_gs",
    name => 'jetti-front',
    noop => true,
  }
}
