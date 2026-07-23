# modules/teleport/manifests/config.pp
#
# Настраивает Teleport: логирование, конфигурацию, сервис и автообновления.

class teleport::config (
  String $tele_env,
  String $tele_grp,
) {
  # Логирование через rsyslog
  file { '/etc/rsyslog.d/13-teleport.conf':
    ensure  => 'present',
    replace => 'yes',
    content => ':rawmsg, contains, "teleport" /var/log/teleport.log
&~',
    notify  => Service['rsyslog'], # Перезапускаем rsyslog при изменении конфига логов
  }

  # Ротация логов Teleport (не зависит от rsyslog)
  file { '/etc/logrotate.d/teleport':
    ensure  => 'present',
    replace => 'yes',
    content => '/var/log/teleport*.log {
      rotate 7
      daily
      missingok
      notifempty
      compress
      size 5M
}',
  }

  # Конфигурация Teleport
  file { '/etc/teleport.yaml':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    require => Package['teleport'],
    notify  => Service['teleport'],
    content => epp(
      'teleport/teleport.yaml.epp',
      {
        'hostname' => $facts['networking']['hostname'],
        'tele_env' => $tele_env,
        'tele_grp' => $tele_grp,
      }
    ),
  }

  # Сервисы
  service { 'teleport':
    ensure => running,
    enable => true,
    hasrestart => true,
  }

  service { 'rsyslog':
    ensure => running,
    enable => true,
    hasrestart => true,
  }

  # Управление автообновлениями Teleport (если доступно)
  exec { 'teleport_enable_updates':
    path    => ['/usr/bin', '/bin', '/usr/local/bin', '/opt/teleport/system/bin'],
    command => 'bash -c "/opt/teleport/system/bin/teleport-update link-package 2>/dev/null || true; /opt/teleport/system/bin/teleport-update enable"',
    user    => 'root',
    onlyif  => 'test -f /opt/teleport/system/bin/teleport-update',
    unless  => '/opt/teleport/system/bin/teleport-update status 2>&1 | grep -q "enabled: true"',
  }

  # После запуска сервиса → включаем автообновления
  Service['teleport']
    -> Exec['teleport_enable_updates']

}
