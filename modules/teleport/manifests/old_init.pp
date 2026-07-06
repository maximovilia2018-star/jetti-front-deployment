class teleport (
  String $version = pick($teleport_version, '16'),
){
  class { 'teleport::teleport_one_time_fix':
    target_version => $version,
  }

  class { 'teleport::teleport_inst':
    install_version => $version,
  }

  include teleport::teleport_config

  Class['teleport::teleport_one_time_fix']
  -> Class['teleport::teleport_inst']
  -> Class['teleport::teleport_config']
}
