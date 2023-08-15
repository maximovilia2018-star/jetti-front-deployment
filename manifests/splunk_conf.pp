class splunk_conf {
  file { "/opt/splunkforwarder/etc/system/local/inputs.conf":
    ensure  => 'present',
    replace => 'yes',
    mode => '0644',
    owner => 'splunk',
    group => 'splunk',
    content => "[monitor:///var/log]
blacklist = journal|AtolFptrWebServer|teamviewer15|installer|zabbix|\.(?:old|1|gz)$
disabled = false
index = ${splunk_inx}
"
 ,
  }

  file { "/opt/splunkforwarder/etc/system/local/outputs.conf":
    ensure  => 'present',
    replace => 'yes',
    mode => '0644',
    owner => 'splunk',
    group => 'splunk',
    content => "[tcpout]
defaultGroup = default-autolb-group

[tcpout:default-autolb-group]
server = ${splunk_srv}:9997

[tcpout-server://${splunk_srv}:9997]
"
 ,
  }
}
