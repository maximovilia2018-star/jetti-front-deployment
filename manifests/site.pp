node 'default' {

  $version = '1.3.49'
  $versionsp = '0.1.6'
  $githubtoken = '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'
  $zabbix = '5.4.5'

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
INSTRUMENTATION_KEY=35fd1bc1-4335-4fea-982c-de47128ca595",
    }
# noop => true,

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

  exec { 'apt-get-update':
    command => "apt-get update -o Dir::Etc::sourcelist='sources.list.d/x100.list' -o Dir::Etc::sourceparts='-' -o APT::Get::List-Cleanup='0'",
    onlyif  => "wget -q -N -P /tmp https://repository.jfd-prod.x100platforma.com:443/artifactory/debian/dists/x100/Release && ! cmp -s /tmp/Release /var/lib/apt/lists/repository.jfd-prod.x100platforma.com_artifactory_debian_dists_x100_Release",
    path    => [ '/usr/bin', '/bin' ],
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
    status=$(curl --location --request GET "https://version-provider.x100-apps.com/api/getversion?environment=development&posid=$posid&psname=$psname" | jq -r ".readytoupdate")
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
    command => "/usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold --force-yes install jetti-front=$version",
    user    => 'root',
    unless  => ["/bin/dpkg -s jetti-front | grep \'Version: $version\'", "/bin/bash /opt/precheck_before_update.sh ${version}"],
  }

  package { 'jetti-front':
    ensure => "$version",
    name => 'jetti-front',
    noop => true,
  }

  package { 'bit-cash-box':
    ensure => 'purged',
    name => 'bit-cash-box',
  }

  package { 'libnotify-bin':
    name => 'libnotify-bin',
  }

  package { 'jetti-front-fiscal-spooler':
    ensure => "$versionsp",
    name => 'jetti-front-fiscal-spooler',
  }

  package { 'libcurl4':
    ensure => "7.68.0-1ubuntu2.7",
    name => 'libcurl4',
  }

  package { 'curl':
    ensure =>'7.68.0-1ubuntu2.7',
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
  package { 'zabbix_proxy':
    name => 'zabbix_proxy',
    ensure => "$zabbix",
  }

  file { '/etc/zabbix/zabbix_agentd.conf':
      ensure  => 'present',
      replace => 'yes',
      content => "PidFile=/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=127.0.0.1
ServerActive=31.148.246.253:10049
Hostname=$hostname
Include=/etc/zabbix/zabbix_agentd.d/*.conf
TLSConnect=psk
TLSAccept=psk
TLSPSKIdentity=PSK X100
TLSPSKFile=/etc/zabbix/zabbix_x100.psk
HostMetadata=x100_linux.autoreg",
      require => Package['zabbix_proxy'],
  }

  file { '/etc/zabbix/zabbix_x100.psk':
      ensure  => 'present',
      replace => 'yes',
      content => '39a21b2b196da15d9d4ee4b53fcf82b8f55b2a8074fff30fb181581ea93a6032',
      require => Package['zabbix_proxy'],
  }

  service { 'zabbix_proxy':
    ensure  => 'running',
    enable  => true,
    require => Package['zabbix_proxy'],
  }
}
