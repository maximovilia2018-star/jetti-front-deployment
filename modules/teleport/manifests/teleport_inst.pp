class teleport::teleport_inst {
  exec { "install-teleport-keyring":
      path    => [ '/usr/bin', '/bin' ],
      command => "wget https://apt.releases.teleport.dev/gpg -O /usr/share/keyrings/teleport-archive-keyring.asc" ,
      user    => 'root',
      unless  => ["ls -l /usr/share/keyrings/teleport-archive-keyring.asc"],
  }

   file {'/etc/apt/sources.list.d/teleport.list':
      ensure => present,
      mode => '0640',
      content => "deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.asc] https://apt.releases.teleport.dev/ubuntu focal stable/v12\n",
   }

  exec { "update-repository":
      path    => [ '/usr/bin', '/bin' ],
      command => "apt update || true" ,
      user    => 'root',
      unless  => ["/bin/dpkg -s teleport | grep \'Version: 12\'"],
  }

  package { 'teleport':
     ensure => 'latest',
#     require => Exec['update-repository'],
  }

}
