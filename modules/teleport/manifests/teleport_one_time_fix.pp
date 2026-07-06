class teleport::teleport_one_time_fix (
  String $target_version,
){
  file { '/usr/local/bin/teleport-one_fix.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/teleport/teleport-one_fix.sh',
  }

  exec { 'run-teleport-recovery':
    command => "/usr/local/bin/teleport-one_fix.sh.sh ${target_version}",
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    user    => 'root',
    # Скрипт вернет 0, если служба лежит или отстает БОЛЕЕ ЧЕМ НА 2 версии (ослепла)
    onlyif  => "/usr/local/bin/teleport-one_fix.sh ${target_version}",
    require => File['/usr/local/bin/teleport-one_fix.sh'],
  }
}
