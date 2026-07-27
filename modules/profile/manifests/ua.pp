#modules/profile/manifests/ua.pp
class profile::ua {

  include profile::base
  include profile::timezone_ua
  include profile::ua_pw_change

  include splunk
  include teleport
  include teamviewer
  include zabbix

}
