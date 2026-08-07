class teleport::teleport_one_time_fix {
  file { '/usr/local/bin/teleport-one-time-fix.sh':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/teleport/teleport-one-time-fix.sh',
  }
  
  exec { 'run-teleport-one-time-fix':
    command => '/usr/local/bin/teleport-one-time-fix.sh',
    creates => '/root/.fix-applied1',  # Выполняется только если этот файл не существует
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    timeout => 300,
    require => [Package['teleport'], File['/usr/local/bin/teleport-one-time-fix.sh']],
  }
}
