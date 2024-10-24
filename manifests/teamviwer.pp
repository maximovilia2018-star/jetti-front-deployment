class teamviwer {
#  file { "/etc/apt/sources.list.d/teamviewer.list":
#    ensure  => 'present',
#    replace => 'yes',
#    content => '###   TeamViewer DEB repository list
#
#deb [signed-by=/usr/share/keyrings/teamviewer-keyring.gpg] https://linux.teamviewer.com/deb stable main
#
# deb https://linux.teamviewer.com/deb preview main
#'
# ,
#  }

  package { 'teamviewer':
    name => 'teamviewer',
    ensure => 'latest',
  }
