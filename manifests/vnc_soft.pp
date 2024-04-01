class vnc_soft {   

  package { 'x11vnc':
    name => 'x11vnc',
  }

  file { "/etc/systemd/system/x11vnc.service":
    ensure  => 'present',
    replace => 'yes',
    mode    => '0644',
    content => "[Unit]
Description=Start x11vnc
After=multi-user.target display-manager.service

[Service]
Type=simple

ExecStart=/bin/sh -c \'/usr/bin/x11vnc -display :0 -forever -rfbport 5900 -xkb -noxrecord -noxfixes -noxdamage -nomodtweak -repeat -shared -norc -auth /var/run/sddm/* -rfbauth /etc/x11vnc.passwd\'
Restart=always
RestartSec=1

ExecStop=/usr/bin/killall x11vnc

[Install]
WantedBy=multi-user.target",
  }

  file { "/root/x11vnc.md5":
    ensure  => 'present',
    replace => 'yes',
    content => "490908e5a321ab478005fde9aa4ccdcd  /etc/x11vnc.passwd",
    mode    => '0600',
  }

  exec { "set-vnc-passwd":
    command => "/usr/bin/x11vnc -storepasswd \"SushiMasterIt\" /etc/x11vnc.passwd" ,
    user    => 'root',
    unless  => ["test -f /etc/x11vnc.passwd", "/usr/bin/md5sum -c --quiet /root/x11vnc.md5"],
  }

  service { 'x11vnc':
    ensure  => 'running',
    enable  => true,
    require => Package['x11vnc'],
  }

}
