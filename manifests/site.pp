
node /(?i)^ru-gs-*/{
  include net_explorer
  include jetti_front
  include jetti_front_fiscal_spooler
  include zabbix_agent
  include base_soft
  include splunk
  $ru_gs = '1.3.75~hf.1'
  $versionsp = '0.1.12'
  $githubtoken = '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'
  $curl = '7.68.0-1ubuntu2.7'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

  exec { "jetti-front":
    command => "/usr/bin/dpkg --configure -a && /usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold --force-yes install jetti-front=$ru_gs && reboot" ,
    user    => 'root',
    unless  => ["/bin/dpkg -s jetti-front | grep -oP \'Version: $ru_gs$\'", "/bin/bash /opt/precheck_before_update.sh ${ru_gs}"],
  }

  package { 'jetti-front':
    ensure => "$ru_gs",
    name => 'jetti-front',
    noop => true,
  }

  package { 'jetti-front-fiscal-spooler':
    ensure => "$versionsp",
    name => 'jetti-front-fiscal-spooler',
  }

  file { "/etc/environment":
    ensure  => 'present',
    replace => 'yes',
    content => "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\"
ENV=\"${environment}\"
INSTRUMENTATION_KEY=${$applicationinsightskey}",
  }

  exec { 'config':
    notify  => Service['jetti-front-fiscal-spooler'],
    command => "cp /tmp/config.production.yaml /opt/jetti-front-fiscal-spooler/config.production.yaml",
    onlyif  => [ "if [ $(curl -o /dev/null -s -w \"%{http_code}\n\" https://$githubtoken@raw.githubusercontent.com/x100group/pos-configuration/main/fiscal-spooler/$hostname/config.production.yaml) = \"200\" ]; then exit 0 ; else exit 1; fi; ", "curl -s https://$githubtoken@raw.githubusercontent.com/x100group/pos-configuration/main/fiscal-spooler/$hostname/config.production.yaml > /tmp/config.production.yaml && ! cmp -s /tmp/config.production.yaml /opt/jetti-front-fiscal-spooler/config.production.yaml" ],
    path    => [ '/usr/bin', '/bin' ],
    provider => 'shell',
    require => Package['jetti-front-fiscal-spooler'],
  }

}

node /(?i)^ru-sm-*/{
  include net_explorer
  include jetti_front
  include jetti_front_fiscal_spooler
  include zabbix_agent
  include base_soft
  include splunk
  $ru_sm = '1.3.75~rc.9'
  $versionsp = '0.1.12'
  $githubtoken = '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'
  $curl = '7.68.0-1ubuntu2.7'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

  exec { "jetti-front":
    command => "/usr/bin/dpkg --configure -a && /usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold --force-yes install jetti-front=$ru_sm && reboot" ,
    user    => 'root',
    unless  => ["/bin/dpkg -s jetti-front | grep -oP \'Version: $ru_sm$\'", "/bin/bash /opt/precheck_before_update.sh ${ru_sm}"],
  }

  package { 'jetti-front':
    ensure => "$ru_sm",
    name => 'jetti-front',
    noop => true,
  }

  package { 'jetti-front-fiscal-spooler':
    ensure => "$versionsp",
    name => 'jetti-front-fiscal-spooler',
  }

  exec { 'config':
    notify  => Service['jetti-front-fiscal-spooler'],
    command => "cp /tmp/config.production.yaml /opt/jetti-front-fiscal-spooler/config.production.yaml",
    onlyif  => [ "if [ $(curl -o /dev/null -s -w \"%{http_code}\n\" https://$githubtoken@raw.githubusercontent.com/x100group/pos-configuration/main/fiscal-spooler/$hostname/config.production.yaml) = \"200\" ]; then exit 0 ; else exit 1; fi; ", "curl -s https://$githubtoken@raw.githubusercontent.com/x100group/pos-configuration/main/fiscal-spooler/$hostname/config.production.yaml > /tmp/config.production.yaml && ! cmp -s /tmp/config.production.yaml /opt/jetti-front-fiscal-spooler/config.production.yaml" ],
    path    => [ '/usr/bin', '/bin' ],
    provider => 'shell',
    require => Package['jetti-front-fiscal-spooler'],
  }

  file { "/etc/environment":
    ensure  => 'present',
    replace => 'yes',
    content => "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\"
ENV=\"${environment}\"
INSTRUMENTATION_KEY=${$applicationinsightskey}",
  }

}

node /(?i)^ua-mp-*/{
  include jetti_front
  include zabbix_agent
  include base_soft
  include splunk
  $ua_mp = '1.3.75~rc.9'
  $githubtoken = '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'
  $curl = '7.68.0-1ubuntu2.7'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

  exec { "jetti-front":
    command => "/usr/bin/dpkg --configure -a && /usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold --force-yes install jetti-front=$ua_mp && reboot" ,
    user    => 'root',
    unless  => ["/bin/dpkg -s jetti-front | grep -oP \'Version: $ua_mp$\'", "/bin/bash /opt/precheck_before_update.sh ${ua_mp}"],
  }

  package { 'jetti-front':
    ensure => "$ua_mp",
    name => 'jetti-front',
    noop => true,
  }

  file { "/etc/environment":
    ensure  => 'present',
    replace => 'yes',
    content => "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\"
ENV=\"${environment}\"
INSTRUMENTATION_KEY=${$applicationinsightskey}",
  }

}

node /(?i)^ua-sm-*/{
  include jetti_front
  include zabbix_agent
  include base_soft
  include splunk
  $ua_sm = '1.3.75~hf.1'
  $githubtoken = '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'
  $curl = '7.68.0-1ubuntu2.7'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

  exec { "jetti-front":
    command => "/usr/bin/dpkg --configure -a && /usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold --force-yes install jetti-front=$ua_sm && reboot" ,
    user    => 'root',
    unless  => ["/bin/dpkg -s jetti-front | grep -oP \'Version: $ua_sm$\'", "/bin/bash /opt/precheck_before_update.sh ${ua_sm}"],
  }

  package { 'jetti-front':
    ensure => "$ua_sm",
    name => 'jetti-front',
    noop => true,
  }

  file { "/etc/environment":
    ensure  => 'present',
    replace => 'yes',
    content => "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\"
ENV=\"${environment}\"
INSTRUMENTATION_KEY=${$applicationinsightskey}",
  }

}

node 'default' {


}
