node 'default' {

  $version = '1.3.72'
  $versionsp = '0.1.12'
  $githubtoken = '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'
  $curl = '7.68.0-1ubuntu2.7'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'


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
      status=$(curl --location --request GET "https://version-provider.x100-apps.com/api/getversion?environment=production&posid=$posid&psname=$psname" | jq -r ".readytoupdate")
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


  package { 'jetti-front-fiscal-spooler':
    ensure => "$versionsp",
    name => 'jetti-front-fiscal-spooler',
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

  file { "/etc/rsyslog.d/10-ansible.conf":
    ensure  => 'present',
    replace => 'yes',
    content => ':rawmsg, contains, "atol-fptr-web-server" /var/log/ATOL-fptr.log
    &~',
  }

  file { "/etc/logrotate.d/ATOL-fptr":
    ensure  => 'present',
    replace => 'yes',
    content => "/var/log/ATOL-fptr.log {
        daily
        rotate 7
        compress
    #    delaycompress
        missingok
        notifempty
        create 0640 syslog adm
    }",
  }

  ### python3

  package { 'python3-pip':
   name => 'python3-pip',
  }

  package { 'CacheControl':
    ensure => '0.12.8',
    provider => pip3,
  }

  package { 'cachetools':
    ensure => '4.2.4',
    provider => pip3,
  }

  package { 'certifi':
    ensure => '2021.10.8',
    provider => pip3,
  }

  package { 'charset-normalizer':
    ensure => '2.0.7',
    provider => pip3,
  }

  package { 'firebase-admin':
    ensure => '5.0.3',
    provider => pip3,
  }

  package { 'google-api-core':
    ensure => '2.2.1',
    provider => pip3,
  }

  package { 'google-api-python-client':
    ensure => '2.28.0',
    provider => pip3,
  }

  package { 'google-auth':
    ensure => '2.3.2',
    provider => pip3,
  }

  package { 'google-auth-httplib2':
    ensure => '0.1.0',
    provider => pip3,
  }

  package { 'google-cloud-core':
    ensure => '2.1.0',
    provider => pip3,
  }

  package { 'google-cloud-firestore':
    ensure => '2.3.4',
    provider => pip3,
  }

  package { 'google-cloud-storage':
    ensure => '1.42.3',
    provider => pip3,
  }

  package { 'google-crc32c':
    ensure => '1.3.0',
    provider => pip3,
  }

  package { 'google-resumable-media':
    ensure => '2.1.0',
    provider => pip3,
  }

  package { 'googleapis-common-protos':
    ensure => '1.53.0',
    provider => pip3,
  }

  package { 'grpcio':
    ensure => '1.41.1',
    provider => pip3,
  }

  package { 'grpcio-status':
    ensure => '1.41.1',
    provider => pip3,
  }

  package { 'httplib2':
    ensure => '0.20.1',
    provider => pip3,
  }

  package { 'idna':
    ensure => '3.3',
    provider => pip3,
  }

  package { 'msgpack':
    ensure => '1.0.2',
    provider => pip3,
  }

  package { 'packaging':
    ensure => '21.2',
    provider => pip3,
  }

  package { 'proto-plus':
    ensure => '1.19.7',
    provider => pip3,
  }

  package { 'protobuf':
    ensure => '3.19.1',
    provider => pip3,
  }

  package { 'pyasn1':
    ensure => '0.4.8',
    provider => pip3,
  }

  package { 'pyasn1-modules':
    ensure => '0.2.8',
    provider => pip3,
  }

  package { 'pyparsing':
    ensure => '2.4.7',
    provider => pip3,
  }

  package { 'requests':
    ensure => '2.26.0',
    provider => pip3,
  }

  package { 'rsa':
    ensure => '4.7.2',
    provider => pip3,
  }

  package { 'six':
    ensure => '1.16.0',
    provider => pip3,
  }

  package { 'uritemplate':
    ensure => '4.1.1',
    provider => pip3,
  }

  package { 'urllib3':
    ensure => '1.26.7',
    provider => pip3,
  }

  file { '/etc/zabbix/scripts':
    ensure => 'directory',
  }

  file { "/etc/zabbix/scripts/net_explorer_prod.py":
    ensure  => 'present',
    replace => 'yes',
    content => '#!/usr/bin/env python3
import sys
import time
import traceback
import firebase_admin
from firebase_admin import credentials, firestore

try:
    arg_names = [\'command\', \'json_cert\', \'dlimit\']
    args = dict(zip(arg_names, sys.argv))

    if \'dlimit\' in args:
        dlimit=int(args[\'dlimit\'])
    else:
        dlimit=1000

    d1=time.time()

    cred = credentials.Certificate(args[\'json_cert\'])
    firebase_admin.initialize_app(cred)
    firestore_db = firestore.client()
    snapshots = list(firestore_db.collection(u\'Employee\').limit(dlimit).order_by(\'FullName\').get())
    d2=time.time()

    print(round((d2-d1)*1000))

except Exception as e:
    print(str(e)+ \'\n\'+traceback.format_exc())
    exit(3)'
 ,
  }

  file { "/etc/zabbix/scripts/x100-jetti-60d148de1870.json":
    ensure  => 'present',
    replace => 'yes',
    content => '{
      "type": "service_account",
      "project_id": "x100-jetti",
      "private_key_id": "60d148de187041e086481e593ac2dd53ba1150e6",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCv1rJtwZKKtHFs\nm80sSdJbqWnoTIHMMtBE3GFNPNuaBrFouWbf3fGQDthinVcnU4PfcZXR1vsoEh1w\nC7TaNLF2Y0Mcd3p0ceah1cxpYoli3e477pynDUAlenGZT40bxEP/vl37WYLWBGKH\ndXr9aLrkRRJRLty/Eci45VnqykSHegYgFNHb/BP+R68JgeqTECkqS/mKW5AHIvBL\nbb6s00hMeEt6qKVGtVPfwitGDfsCcFv9GHB+45gPfmATmcRK5nnZf62GElu7Ho65\nHV5+GGN1+ZWxM3mSnzh3XFhkgq+bBo3zkbe0QYJGxH+JdqOqu3jNMKVXY5ZAg7Hq\nhMOglbihAgMBAAECggEAQrOqTslByh0F88GsVHMSeZPr6WNwT2ItMBn7TR3bXfPR\nA51lAWIDWvbOraXq5C+hlDbVstqevoYUpabDLY0Ujoi78gX+rUJxzw03s/hdjmQK\nlbB/uzzjCvSGODZ9nD1Y4CA6LXk4kO/r4l+1zoAWeTYcazBgK5jW8BCMiey9jzgh\nOBzsx+SoKOI+oQXYBBo5cWxXpInR+pyHfiTiae7nZ5asWwCaaJ2PqittC0G3ZXL4\n2ldjPdmrvrN1SAU4fV5e2AMkpKSayz1ZZzkWEdQr6xYkfO2P8Rmxh9o1j3BfEaAH\nry3Ui3puu5oTa/fId72/PdEwVB5MdmDU9h8DiYY1OwKBgQDUYIu9pPVLTA+0G0WB\nHLOKd5ZzF3clWW0dWaUG4XT5PedPDfkszYNRXSh9XUj2vrdug3DjsAgGpZ4/GhKw\nY7gFtXvlRNl7ZJ8LDljkWvd/7D89mqBflKcYvw7EdJQnqOywFBzDJCOXxRVm1c2a\nA9hiBssLa/krGYSF19yI4FaVowKBgQDT9NgLzxb4lYaZ5mkChjucZnVm+H89JNYZ\nrluIi+BKSLsShBTpazom90enGHmcp6ps+vO60y77SxrHNkRmzpZg6/NMr/1JGxiB\n4oXwB1ADOcxjvoKd3BLhaNcYoPdlpmnn2VW52UvGCvyz+11Th+ETdBHEo/2/psZg\nz9JddUn06wKBgQCePKkhzgyt46g3q7IntvjXDK9eZXdyrqSsH6Tj8Yw0QLldn62u\nghl7wAtxDNZWclc90lWEcB4qxa+YmJagMkxkhIohkyDv3VLa6/+zdUu/VojwH4uq\na5nsyD36hln1Ctn/f5zGkOCsLj359wdP39mTgDg89GAcitDA4MsCeRRKPQKBgQC3\no2Hv0UvYskw9WOjQXBaXqhm7zj8Hbbvl4i/B/ValZaBXKYKovdNTYVl+R3FOLeI1\nq7OxwTjqVibsRHM9E24sqSFR5wSu6z/vgKCE1wEW2mPgY3XtaXgePeRmnUfblTQa\nwS1J6R+ChZBuK7GvJoH2hdDDK0Y1XzxvMn/To0QhYwKBgEeQQqnpSwqKL9ERwdqv\n9YNbbHolTGCCvUdGcyO37fletoSs0XNDjXnNCqooaaabTYNmUrGeir6Wase25j6s\n3zSDOJw2A8tkALq1lDHxkLaBeLqHxq0vfZK750wbyuDi555uWi7e/pfc79KCl8xG\nNSsmkGBfk77kOJReqmrc5R6f\n-----END PRIVATE KEY-----\n",
      "client_email": "zabbix-agent@x100-jetti.iam.gserviceaccount.com",
      "client_id": "114736922978801848972",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/zabbix-agent%40x100-jetti.iam.gserviceaccount.com"
    }',
  }

  file { "/etc/zabbix/zabbix_agentd.d/UserParameter_firestore.conf":
    ensure  => 'present',
    replace => 'yes',
    content => 'UserParameter=x100.jetti.firestore.check.python,python3 /etc/zabbix/scripts/net_explorer_prod.py /etc/zabbix/scripts/x100-jetti-60d148de1870.json 1000',
  }

  service { 'zabbix-agent':
    ensure  => 'running',
    enable  => true,
    hasrestart => true,
    subscribe => File["/etc/zabbix/scripts/net_explorer_prod.py","/etc/zabbix/scripts/x100-jetti-60d148de1870.json","/etc/zabbix/zabbix_agentd.d/UserParameter_firestore.conf"],
  }
}
