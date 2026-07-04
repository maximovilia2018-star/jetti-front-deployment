# modules/splunk_ua/manifests/config.pp
#
# Настройка Splunk Universal Forwarder.

class splunk_ua::config (
  String $splunk_srv,
  String $splunk_inx,
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
blacklist = journal|AtolFptrWebServer|teamviewer15|installer|\.(?:old|1|gz)$
disabled = false
index = ${splunk_inx}
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
server = ${splunk_srv}:9997

[tcpout-server://${splunk_srv}:9997]
",
    require => File[$conf_dir],
    notify  => Service['splunk'],
  }

}
