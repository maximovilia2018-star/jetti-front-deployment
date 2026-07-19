# root_ca_cert.pp - отключение устаревшего корневого сертификата Let's Encrypt
class root_ca_cert {
  file_line { 'disable_dst_root_ca_x3':
    ensure  => 'present',
    path    => '/etc/ca-certificates.conf',
    line    => '!mozilla/DST_Root_CA_X3.crt',
    match   => '^!?mozilla/DST_Root_CA_X3.crt$',
    require => Package['ca-certificates'],
    notify  => Exec['rebuild_ca_certificates'],
  }

  # Пересборка хранилища (выполняется один раз при изменении файла выше).
  exec { 'rebuild_ca_certificates':
    path        => ['/usr/sbin', '/sbin', '/usr/bin', '/bin'],
    command     => 'update-ca-certificates',
    refreshonly => true,
    require     => Package['ca-certificates'],
  }
}
