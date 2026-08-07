class swap_on(
    $swapfile       = '/swapfile',
    $swapfilesize   = '4096'
) {
  exec { 'Create swap file':
    command => "/bin/dd if=/dev/zero of=${swapfile} bs=1M count=${swapfilesize}",
    creates => $swapfile,
  }

  exec { 'Attach swap file':
    command => "/sbin/mkswap ${swapfile} && /sbin/swapon ${swapfile}",
    require => Exec['Create swap file'],
    unless  => "/sbin/swapon -s | grep ${swapfile}",     
  }                                                      
                                                         
  exec { 'Add swap in fstab':                            
    command => "/usr/bin/echo ${swapfile}  none swap sw 0 0 >> /etc/fstab",
    require => Exec['Create swap file'],                 
    unless  => "/usr/bin/grep ${swapfile} /etc/fstab",   
  }
}
