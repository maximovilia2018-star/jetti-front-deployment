#modules/profile/manifests/ua_t.pp
class profile::ua_t {
  $zbx_srv_ua = 'zabbix6active.x100group.com:10051'  

  include profile::base
  include profile::timezone_ua
  include profile::ua_pw_change

  include splunk
  include teamviewer
  include teamviewer::info
  class { 'zabbix':
    zabbix_srv => $zbx_srv_ua,
  }

}
