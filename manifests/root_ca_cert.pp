class root_ca_cert {
  # Выполняем правку конфига, если там остался старый сертификат Let's Encrypt
  exec { 'Disable expired DST Root CA X3':
    path    => ['/usr/bin', '/bin'],
    command => "sed -i 's/mozilla\\/DST_Root_CA_X3.crt/!mozilla\\/DST_Root_CA_X3.crt/g' /etc/ca-certificates.conf",
    onlyif  => "grep -q '^mozilla\\/DST_Root_CA_X3.crt' /etc/ca-certificates.conf",
    notify  => Exec['Rebuild CA certificates store'],
  }

  # Благодаря refreshonly она сработает ОДИН РАЗ за всю жизнь.
  exec { 'Rebuild CA certificates store':
    path        => ['/usr/sbin', '/sbin', '/usr/bin', '/bin'],
    command     => 'update-ca-certificates --fresh',
    user        => 'root',
    refreshonly => true,                                     
  }
}
