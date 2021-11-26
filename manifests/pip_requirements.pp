class pip_requirements {
  package { 'python3-pip':
   name => 'python3-pip',
  }

  package { 'CacheControl':
    ensure => '0.12.8',
    provider => pip3,
  }

  package { 'cachetools':
    ensure => '4.2.4',
    provider => pip3,
  }

  package { 'certifi':
    ensure => '2021.10.8',
    provider => pip3,
  }

  package { 'charset-normalizer':
    ensure => '2.0.7',
    provider => pip3,
  }

  package { 'firebase-admin':
    ensure => '5.0.3',
    provider => pip3,
  }

  package { 'google-api-core':
    ensure => '2.2.1',
    provider => pip3,
  }

  package { 'google-api-python-client':
    ensure => '2.28.0',
    provider => pip3,
  }

  package { 'google-auth':
    ensure => '2.3.2',
    provider => pip3,
  }

  package { 'google-auth-httplib2':
    ensure => '0.1.0',
    provider => pip3,
  }

  package { 'google-cloud-core':
    ensure => '2.1.0',
    provider => pip3,
  }

  package { 'google-cloud-firestore':
    ensure => '2.3.4',
    provider => pip3,
  }

  package { 'google-cloud-storage':
    ensure => '1.42.3',
    provider => pip3,
  }

  package { 'google-crc32c':
    ensure => '1.3.0',
    provider => pip3,
  }

  package { 'google-resumable-media':
    ensure => '2.1.0',
    provider => pip3,
  }

  package { 'googleapis-common-protos':
    ensure => '1.53.0',
    provider => pip3,
  }

  package { 'grpcio':
    ensure => '1.41.1',
    provider => pip3,
  }

  package { 'grpcio-status':
    ensure => '1.41.1',
    provider => pip3,
  }

  package { 'httplib2':
    ensure => '0.20.1',
    provider => pip3,
  }

  package { 'idna':
    ensure => '3.3',
    provider => pip3,
  }

  package { 'msgpack':
    ensure => '1.0.2',
    provider => pip3,
  }

  package { 'packaging':
    ensure => '21.2',
    provider => pip3,
  }

  package { 'proto-plus':
    ensure => '1.19.7',
    provider => pip3,
  }

  package { 'protobuf':
    ensure => '3.19.1',
    provider => pip3,
  }

  package { 'pyasn1':
    ensure => '0.4.8',
    provider => pip3,
  }

  package { 'pyasn1-modules':
    ensure => '0.2.8',
    provider => pip3,
  }

  package { 'pyparsing':
    ensure => '2.4.7',
    provider => pip3,
  }

  package { 'requests':
    ensure => '2.26.0',
    provider => pip3,
  }

  package { 'rsa':
    ensure => '4.7.2',
    provider => pip3,
  }

  package { 'six':
    ensure => '1.16.0',
    provider => pip3,
  }

  package { 'uritemplate':
    ensure => '4.1.1',
    provider => pip3,
  }

  package { 'urllib3':
    ensure => '1.26.7',
    provider => pip3,
  }

}
