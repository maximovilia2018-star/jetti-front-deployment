# modules/splunk_ua/manifests/config.pp
#
# Настройка Splunk Universal Forwarder.

class splunk_ua::config (
  String $splunk_srv,
  String $splunk_inx,
) {

  # Директория конфигурации
  file { '/opt/splunkforwarder/etc/system/local':
    ensure  => directory,
    owner   => 'splunk',
    group   => 'splunk',
    mode    => '0755',
  }

  # inputs.conf - какие логи собирать
  file { '/opt/splunkforwarder/etc/system/local/inputs.conf':
    ensure  => file,
    owner   => 'splunk',
    group   => 'splunk',
    mode    => '0644',
    content => @("EOF"),
[monitor:///var/log]
blacklist = journal|AtolFptrWebServer|teamviewer15|installer|\.(?:old|1|gz)$
disabled = false
index = ${splunk_inx}
| EOF
    require => File['/opt/splunkforwarder/etc/system/local'],
    notify => Service['splunk'],
  }

  # outputs.conf - куда логи отправлять
  file { '/opt/splunkforwarder/etc/system/local/outputs.conf':
    ensure  => file,
    owner   => 'splunk',
    group   => 'splunk',
    mode    => '0644',
    content => @("EOF"),
[tcpout]
defaultGroup = default-autolb-group

[tcpout:default-autolb-group]
server = ${splunk_srv}:9997

[tcpout-server://${splunk_srv}:9997]
| EOF
    require => File['/opt/splunkforwarder/etc/system/local'],
    notify => Service['splunk'],
  }

}
