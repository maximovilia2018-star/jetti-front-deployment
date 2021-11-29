class root_ca_cert {
  exec { 'Update CA certificates':
    command => "/usr/bin/sed -i \'s/mozilla\/DST_Root_CA_X3.crt/!mozilla\/DST_Root_CA_X3.crt/g\' /etc/ca-certificates.conf && update-ca-certificates --fresh",
    onlyif  => "/usr/bin/grep \'^mozilla\\/DST_Root_CA_X3.crt\' /etc/ca-certificates.conf",
  }
