# modules/profile_base/manifests/init.pp
class profile_base {
  include profile_base::base_soft
  include profile_base::swapfile
  include profile_base::journald
  include profile_base::log_atol_config
  include profile_base::root_ca_cert
#  include profile_base::timezone
#  include ua_pw_change
}
