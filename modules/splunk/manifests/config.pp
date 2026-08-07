# modules/splunk/manifests/config.pp
#
# Настройка Splunk Universal Forwarder.

class splunk::config (
  String $int_srv,
  String $int_inx,
) {

  $conf_dir = '/opt/splunkforwarder/etc/system/local'

  # Директория конфигурации
  file { $conf_dir:
    ensure => directory,
    owner  => 'splunk',
    group  => 'splunk',
    mode   => '0755',
  }

  # inputs.conf - какие логи собирать
  file { "${conf_dir}/inputs.conf":
    ensure  => file,
    owner   => 'splunk',
    group   => 'splunk',
    mode    => '0644',
    content => "[monitor:///var/log]
blacklist = journal|AtolFptrWebServer|teamviewer15|installer|zabbix|\.(?:old|1|gz)$
disabled = false
index = ${int_inx}
",
    require => File[$conf_dir],
    notify  => Service['splunk'],
  }

  # outputs.conf - куда логи отправлять
  file { "${conf_dir}/outputs.conf":
    ensure  => file,
    owner   => 'splunk',
    group   => 'splunk',
    mode    => '0644',
    content => "[tcpout]
defaultGroup = default-autolb-group

[tcpout:default-autolb-group]
server = ${int_srv}:9997

[tcpout-server://${int_srv}:9997]
",
    require => File[$conf_dir],
    notify  => Service['splunk'],
  }

}
