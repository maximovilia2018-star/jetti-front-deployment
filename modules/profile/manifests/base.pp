#modules/profile/manifests/base.pp
class profile::base {

  include profile::base_soft
  include profile::journald
  include profile::root_ca_cert
  include profile::swapfile
  include profile::puppet_agent
  include profile::nexus_repo

}
