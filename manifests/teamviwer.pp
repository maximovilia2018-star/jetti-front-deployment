class teamviwer {
  package { 'teamviewer':
    name => 'teamviewer',
    ensure => 'latest',
  }
}
