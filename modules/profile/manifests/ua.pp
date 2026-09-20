#modules/profile/manifests/ua.pp
class profile::ua {
  #$zbx_srv_ua = pick($zbx_srv, $::zbx_srv, 'zabbix6active.x100group.com:10051')
  $zbx_srv_ua = pick(getvar('zbx_srv'), 'zabbix6active.x100group.com:10051')

  include profile::base
  include profile::timezone_ua
  include profile::ua_pw_change

  include splunk
  include teleport
  include teamviewer
  class { 'zabbix':
    zabbix_srv => $zbx_srv_ua,
  }

}
