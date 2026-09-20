#modules/profile/manifests/ae.pp
class profile::ae {
  $zbx_srv_ae = 'zabbix6active.x100group.com:10051'

  include profile::base
  include profile::timezone_ae
#  include profile::ua_pw_change

  include splunk
  include teleport
  include teamviewer
  class { 'zabbix':
    zabbix_srv => $zbx_srv_ae,
  }

}
