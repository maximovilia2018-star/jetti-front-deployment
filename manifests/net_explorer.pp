class net_explorer {

  file { '/etc/zabbix/scripts':
    ensure => 'directory',
  }

  file { '/etc/zabbix/zabbix_agentd.d':
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
    content => 'Timeout=30
UserParameter=x100.jetti.firestore.check.python,python3 /etc/zabbix/scripts/net_explorer_prod.py /etc/zabbix/scripts/x100-jetti-60d148de1870.json 1000
 ',
  }

  service { 'zabbix-agent-explorer':
    name => 'zabbix-agent',
    ensure  => 'running',
    enable  => true,
    hasrestart => true,
    subscribe => File["/etc/zabbix/zabbix_agentd.conf", "/etc/zabbix/scripts/net_explorer_prod.py","/etc/zabbix/scripts/x100-jetti-60d148de1870.json","/etc/zabbix/zabbix_agentd.d/UserParameter_firestore.conf"],
  }

}
