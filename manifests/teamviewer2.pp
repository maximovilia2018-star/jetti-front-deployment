# teamviewer.pp - production POS installation (minimal & stable)
class teamviewer2 (
  String $user = 'bit',
) {

  apt::source { 'teamviewer':
    location => 'https://download.teamviewer.com/deb',
    release  => 'stable',
    repos    => 'main',
    include  => {
      src => false,
    },
    key      => {
      id     => 'BFF25D5E3E136D0F4A13BBA953C3C4D46FDD44A8',
      source => 'https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc',
    },
  }

  package { 'teamviewer':
    ensure => installed,
  }

  service { 'teamviewerd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => Package['teamviewer'],
  }

  file { "/home/${user}/.config":
    ensure => directory,
    owner  => $user,
    group  => $user,
    mode   => '0755',
  }

  file { "/home/${user}/.config/autostart":
    ensure  => directory,
    owner   => $user,
    group   => $user,
    mode    => '0755',
    require => File["/home/${user}/.config"],
  }

  file { "/home/${user}/.config/autostart/TeamViewer.desktop":
    ensure  => file,
    owner   => $user,
    group   => $user,
    mode    => '0644',
    content => "[Desktop Entry]
Type=Application
Name=TeamViewer
Exec=/usr/bin/teamviewer
X-GNOME-Autostart-enabled=true
",
    require => [
      Package['teamviewer'],
      File["/home/${user}/.config/autostart"],
    ],
  }

}
