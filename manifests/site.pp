node 'default' {

  $version = '1.3.36'
  $versionsp = '0.1.6'
  $githubtoken = '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'

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
ENV=\"${environment}\"",
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
    content => "#!/bin/bash
FILE=/home/bit/.config/jetti-front/config1.json
if test -f \"$FILE\"; then
    echo \"$FILE exists.\"
    posid=$(jq -r \".posId\" /home/bit/.config/jetti-front/config.json)
    status=$(curl --location --request GET \"https://version-provider.x100-apps.com/api/getversion?environment=${environment}&posid=$posid\" | jq -r \".readytoupdate\")
    if $status == \"false\"; then
      exit 1
    else
      echo \"We can update\"
    fi
fi",
    mode    => '0755',
  }

  exec { 'precheck_before_update':
    command     => '/bin/bash -c /opt/precheck_before_update.sh',
    refreshonly => true,
    require     => File['/opt/precheck_before_update.sh'],
  }

  exec { "jetti-front":
    command => "/usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold --force-yes install jetti-front=$version",
    user   => 'root',
    notify => Exec['precheck_before_update'],
    unless => "/bin/dpkg -s jetti-front | grep \'Version: $version\'",
  }
  # package { 'jetti-front':
  #   ensure => "$version",
  #   name => 'jetti-front',
  #   notify => Exec['precheck_before_update'],
  #   install_options => -d,
  # }

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
    ensure => "7.68.0-1ubuntu2.5",
    name => 'libcurl4',
  }

  package { 'curl':
    ensure =>'7.68.0-1ubuntu2.5',
    name => 'curl',
  }

  package { 'jq':
    name => 'jq',
  }

  package { 'unattended-upgrades':
    ensure => 'purged',
    name => 'unattended-upgrades',
  }
}
