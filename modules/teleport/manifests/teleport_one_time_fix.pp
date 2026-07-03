class teleport::teleport_one_time_fix (
  String $target_version,
){
  file { '/usr/local/bin/teleport-recovery.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/teleport/teleport-recovery.sh',
  }

  exec { 'run-teleport-recovery':
    command => "/usr/local/bin/teleport-recovery.sh ${target_version}",
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    user    => 'root',
    # Скрипт вернет 0, если служба лежит или отстает БОЛЕЕ ЧЕМ НА 2 версии (ослепла)
    onlyif  => "/usr/local/bin/teleport-recovery.sh ${target_version}",
    require => File['/usr/local/bin/teleport-recovery.sh'],
  }
}
