node 'default' {
  # command => "apt-get update -o Dir::Etc::sourcelist='sources.list.d/x100.list' -o Dir::Etc::sourceparts='-' -o APT::Get::List-Cleanup='0'"
  $version = '1.3.72'
  $versionsp = '0.1.12'
  $githubtoken = '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'
  $curl = '7.68.0-1ubuntu2.7'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $zabbix = '1:5.4.6-1+debian10'

  file { '/etc/apt/sources.list.d/x100.list':
      ensure  => 'present',
      replace => 'no',
      content => 'deb [trusted=yes] https://repository.jfd-prod.x100platforma.com/artifactory/debian x100 front',
      mode    => '0644',
  }

  file { "/etc/environment":
    ensure  => 'present',
    replace => 'yes',
    content => "PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\"
ENV=\"${environment}\"
INSTRUMENTATION_KEY=${$applicationinsightskey}",
  }

  file { '/etc/apt/sources.list.d/focal-updates.list':
      ensure  => 'present',
      replace => 'no',
      content => 'deb http://archive.ubuntu.com/ubuntu focal-updates main restricted universe multiverse',
      mode    => '0644',
  }

  exec { 'nodesource':
    command => "wget -O - https://deb.nodesource.com/setup_14.x | bash -",
    unless  => "test -f /etc/apt/sources.list.d/nodesource.list",
    path    => [ '/usr/bin', '/bin' ],
  }


  service { 'jetti-front-fiscal-spooler':
    ensure  => 'running',
    enable  => true,
    require => Package['jetti-front-fiscal-spooler'],
  }

  exec { 'config':
    notify  => Service['jetti-front-fiscal-spooler'],
    command => "cp /tmp/config.production.yaml /opt/jetti-front-fiscal-spooler/config.production.yaml",
    onlyif  => [ "if [ $(curl -o /dev/null -s -w \"%{http_code}\n\" https://$githubtoken@raw.githubusercontent.com/x100group/pos-configuration/main/fiscal-spooler/$hostname/config.production.yaml) = \"200\" ]; then exit 0 ; else exit 1; fi; ", "curl -s https://$githubtoken@raw.githubusercontent.com/x100group/pos-configuration/main/fiscal-spooler/$hostname/config.production.yaml > /tmp/config.production.yaml && ! cmp -s /tmp/config.production.yaml /opt/jetti-front-fiscal-spooler/config.production.yaml" ],
    path    => [ '/usr/bin', '/bin' ],
    provider => 'shell',
    require => Package['jetti-front-fiscal-spooler'],
  }

  file { '/home/bit/.config/autostart/x100-front.desktop':
      ensure  => 'present',
      replace => 'yes',
      content => '[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=CashDesk
Comment=Cash Desk Sushi Master
Exec=jetti-front
Hidden=false
NoDisplay=false
Terminal=false',
      mode    => '0644',
  }

  package { 'bit-cash-box':
    ensure => 'purged',
    name => 'bit-cash-box',
  }

  exec { 'apt-get-update':
    command => "apt-get install ca-certificates && apt-get update || true",
    onlyif  => "wget -q -N -P /tmp https://repository.jfd-prod.x100platforma.com:443/artifactory/debian/dists/x100/Release && ! cmp -s /tmp/Release /var/lib/apt/lists/repository.jfd-prod.x100platforma.com_artifactory_debian_dists_x100_Release",
    path    => [ '/usr/bin', '/bin' ],
  }

  package { 'libnotify-bin':
    name => 'libnotify-bin',
  }

  file { '/opt/precheck_before_update.sh':
    ensure  => 'present',
    replace => 'yes',
    content => '#!/bin/bash
FILE=/home/bit/.config/jetti-front/config.json
if test -f "$FILE"; then
    echo "$FILE exists."
    posid=$(jq -r ".posId" /home/bit/.config/jetti-front/config.json)
    psname=$(hostname)
    VER=$1
    status=$(curl --location --request GET "https://version-provider.x100-apps.com/api/getversion?environment=staging&posid=$posid&psname=$psname" | jq -r ".readytoupdate")
    if [ $status = "false" ]; then
      apt-get install --download-only -y jetti-front=$VER
      exit 0
    else
      echo "We can update"
      exit 1
    fi
    exit 1
fi
exit 1',
    mode    => '0755',
  }

  exec { "jetti-front":
    command => "/usr/bin/dpkg --configure -a && /usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold --force-yes install jetti-front=$version && reboot" ,
    user    => 'root',
    unless  => ["/bin/dpkg -s jetti-front | grep \'Version: $version\'", "/bin/bash /opt/precheck_before_update.sh ${version}"],
  }

  package { 'jetti-front':
    ensure => "$version",
    name => 'jetti-front',
    noop => true,
  }

  exec { "jetti-front-fiscal-spooler":
    command => "/usr/bin/dpkg --configure -a && /usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold --force-yes install jetti-front-fiscal-spooler=$versionsp" ,
    user    => 'root',
    unless  => ["/bin/dpkg -s jetti-front-fiscal-spooler | grep \'Version: $versionsp\'"],
  }

  package { 'jetti-front-fiscal-spooler':
    ensure => "$versionsp",
    name => 'jetti-front-fiscal-spooler',
    noop => true,
  }

  package { 'libcurl4':
    ensure => "$curl",
    name => 'libcurl4',
  }

  package { 'curl':
    ensure =>"$curl",
    name => 'curl',
  }

  package { 'jq':
    name => 'jq',
  }

  package { 'unattended-upgrades':
    ensure => 'purged',
    name => 'unattended-upgrades',
  }
  ### zabbix

  exec { "install-zabbix-repository":
      command => "/usr/bin/wget https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian10_all.deb && dpkg -i zabbix-release_5.4-1+debian10_all.deb && apt update" ,
      user    => 'root',
      unless  => ["/bin/dpkg -s zabbix-agent | grep \'Version: \'"],
  }

  package { 'zabbix-agent':
    name => 'zabbix-agent',
  }

  file { '/etc/zabbix/zabbix_agentd.conf':
      ensure  => 'present',
      replace => 'yes',
      content => "PidFile=/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=100
Server=127.0.0.1
ServerActive=31.148.246.253:10049
Hostname=$hostname
Include=/etc/zabbix/zabbix_agentd.d/*.conf
TLSConnect=psk
TLSAccept=psk
TLSPSKIdentity=PSK X100
TLSPSKFile=/etc/zabbix/zabbix_x100.psk
HostMetadata=x100_linux.autoreg",
  }

  file { '/etc/zabbix/zabbix_x100.psk':
      ensure  => 'present',
      replace => 'yes',
      content => '39a21b2b196da15d9d4ee4b53fcf82b8f55b2a8074fff30fb181581ea93a6032',
  }

  service { 'zabbix-agent':
    ensure  => 'running',
    enable  => true,
    require => Package['zabbix-agent'],
    hasrestart => true,
    subscribe => File["/etc/zabbix/zabbix_agentd.conf"],
  }
}

node /(?i)^ua-mp-*/{
  $ua_mp = '1.3.72'

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
  $ru_gs = '1.3.72'

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
