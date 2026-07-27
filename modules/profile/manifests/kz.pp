#modules/profile/manifests/kz.pp
class profile::kz {
  # Инфраструктурные константы региона KZ
  $zbx_srv_ua = pick($zbx_srv, $::zbx_srv, 'zabbix5.x100group.com:10049')

  # Базовый слой компании
  include profile::base
  include profile::log_atol_config
#  include profile::ru_pw_change

  class { 'zabbix':
    zabbix_srv => $zbx_srv_ua,
  }
#  include vnc_soft

}
