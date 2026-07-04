class zabbix::pip_requirements {
  package { 'python3-pip':
    ensure => 'present',
  }

  Package {
    provider => 'pip3',
    require  => Package['python3-pip'],
  }

  # 3. Компактное объявление пакетов
  package { 'CacheControl': ensure => '0.12.8' }
  package { 'cachetools': ensure => '4.2.4' }
  package { 'certifi': ensure => '2021.10.8' }
  package { 'charset-normalizer': ensure => '2.0.7' }
  package { 'firebase-admin': ensure => '5.0.3' }
  package { 'google-api-core': ensure => '2.2.1' }
  package { 'google-api-python-client': ensure => '2.28.0' }
  package { 'google-auth': ensure => '2.3.2' }
  package { 'google-auth-httplib2': ensure => '0.1.0' }
  package { 'google-cloud-core': ensure => '2.1.0' }
  package { 'google-cloud-firestore': ensure => '2.3.4' }
  package { 'google-cloud-storage': ensure => '1.42.3' }
  package { 'google-crc32c': ensure => '1.3.0' }
  package { 'google-resumable-media': ensure => '2.1.0' }
  package { 'googleapis-common-protos': ensure => '1.53.0' }
  package { 'grpcio': ensure => '1.41.1' }
  package { 'grpcio-status': ensure => '1.41.1' }
  package { 'httplib2': ensure => '0.20.1' }
  package { 'idna': ensure => '3.3' }
  package { 'msgpack': ensure => '1.0.2' }
  package { 'packaging': ensure => '21.2' }
  package { 'proto-plus': ensure => '1.19.7' }
  package { 'protobuf': ensure => '3.19.1' }
  package { 'pyasn1': ensure => '0.4.8' }
  package { 'pyasn1-modules': ensure => '0.2.8' }
  package { 'pyparsing': ensure => '2.4.7' }
  package { 'requests': ensure => '2.26.0' }
  package { 'rsa': ensure => '4.7.2' }
  package { 'six': ensure => '1.16.0' }
  package { 'uritemplate': ensure => '4.1.1' }
  package { 'urllib3': ensure => '1.26.7' }

}
