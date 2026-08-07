class teleport::teleport_inst {
  exec { "install-teleport-keyring":
      path    => [ '/usr/bin', '/bin' ],
      command => "wget https://apt.releases.teleport.dev/gpg -O /usr/share/keyrings/teleport-archive-keyring.asc" ,
      user    => 'root',
      # Вместо ls лучше проверять физическое существование файла через тест -f
      unless  => "test -f /usr/share/keyrings/teleport-archive-keyring.asc",
  }

  file {'/etc/apt/sources.list.d/teleport.list':
      ensure => present,
      mode => '0640',
      content => "deb [signed-by=/usr/share/keyrings/teleport-archive-keyring.asc] https://apt.releases.teleport.dev/ubuntu focal stable/v15\n",
      # Если файл репозитория изменился или создался, мы пинаем exec обновиться
      notify  => Exec['update-repository'], 
  }

  exec { "update-repository":
      path    => [ '/usr/bin', '/bin' ],
      command => "apt update || true" ,
      user    => 'root',
#      unless  => ["/bin/dpkg -s teleport | grep \'Version: 15\'"],
      # Выполнять команду ТОЛЬКО тогда, когда пришел сигнал (notify)
      refreshonly => true, 
  }

  package { 'teleport':
     ensure  => 'latest',
#     require => Exec['update-repository'],
     require => [ Exec['install-teleport-keyring'], File['/etc/apt/sources.list.d/teleport.list'] ],
  }
}
