class swap_on (
  String $swapfile     = '/swapfile',
  String $swapfilesize = '4096'
) {

  exec { 'Create swap file':
    command => "/bin/dd if=/dev/zero of=${swapfile} bs=1M count=${swapfilesize}",
    creates => $swapfile,
    path    => ['/bin', '/usr/bin'],
  }

  file { "Set permissions for ${swapfile}":
    ensure  => 'present',
    path    => $swapfile,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Exec['Create swap file'],
    before  => Exec['Attach swap file'],
  }

  exec { 'Attach swap file':
    command => "/sbin/mkswap ${swapfile} && /sbin/swapon ${swapfile}",
    path    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
    require => Exec['Create swap file'],
    unless  => "/sbin/swapon -s | /bin/grep -qE '^${swapfile}\\s'",
  }

  file_line { 'Add swap in fstab':
    ensure => 'present',
    path   => '/etc/fstab',
    line   => "${swapfile} none swap sw 0 0",
    match  => "^${swapfile}\\s",
  }

}
