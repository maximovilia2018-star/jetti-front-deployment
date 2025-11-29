class teleport::teleport_fix {
  file { '/usr/local/bin/teleport-fix.sh':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => @(EOT)
#!/bin/bash
set -e  # Выход при любой ошибке

MARKER_FILE="/root/.fix-teleport"
if [ -f "$MARKER_FILE" ]; then
    exit 0
fi

systemctl stop teleport 2>/dev/null || true
sleep 3

if [ -f "/etc/teleport.yaml" ]; then
    cp /etc/teleport.yaml /etc/teleport.yaml.backup
fi

apt-get remove -y teleport 2>/dev/null || true
rm -rf /opt/teleport 2>/dev/null || true
rm -rf /var/lib/teleport 2>/dev/null || true
rm -rf /etc/systemd/system/teleport.service.d 2>/dev/null || true
rm -rf /etc/systemd/system/teleport.service.wants 2>/dev/null || true
rm -f /etc/systemd/system/teleport* 2>/dev/null || true

apt-get update
apt-get install -y teleport

if [ -f "/etc/teleport.yaml.backup" ]; then
    cp /etc/teleport.yaml.backup /etc/teleport.yaml
fi

if [ -f "/opt/teleport/system/bin/teleport-update" ]; then
    /opt/teleport/system/bin/teleport-update enable
fi

systemctl daemon-reload
systemctl enable teleport --now
systemctl restart teleport

touch "$MARKER_FILE"
      | EOT
  }

  exec { 'run-teleport-fix':
    command => '/usr/local/bin/teleport-fix.sh',
    creates => '/root/.fix-teleport',
    path    => ['/bin', '/usr/bin', '/usr/local/bin'],
    timeout => 300,
    require => File['/usr/local/bin/teleport-fix.sh'],
  }
}
