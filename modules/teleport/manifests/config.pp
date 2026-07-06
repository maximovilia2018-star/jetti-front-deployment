# modules/teleport/manifests/config.pp
#
# Настраивает Teleport: логирование, конфигурацию, сервис и автообновления.

class teleport::config {
#class teleport::config (
  # Переменные из верхнего scope (с проверкой)
  #String $tele_env   = 'unknown',
  #String $tele_group = 'unknown',
#) {
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
    content => '/var/log/teleport.log {
      rotate 7
      daily
      missingok
      notifempty
      compress
      size 5M
}',
    # Убран некорректный notify, logrotate подхватит файл при следующем раунде cron
  }

  # Конфигурация Teleport
  file { '/etc/teleport.yaml':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0640',
      replace => 'yes',
      content => "version: v3
teleport:
  nodename: ${facts['networking']['hostname']}
  auth_token: 0c3a633af933fbb243a3a9f7fa37c347382f444e66ec3685
  data_dir: /var/lib/teleport
  proxy_server: teleport.x100group.com:443
  log:
    output: stderr
    severity: WARNING
    format:
      output: text
  ca_pin: sha256:7600b3aa6b6579796258000802fbcd9c2ed3dcdb7fb70124fcc94fb0e99879c5
  diag_addr: \"\"
auth_service:
  enabled: \"no\"
ssh_service:
  enabled: \"yes\"
  labels:
    env: \"${tele_env}\"
    group: \"${tele_group}\"
  commands:
  - name: hostname
    command: [hostname]
    period: 1m0s
proxy_service:
  enabled: \"no\"
  https_keypairs: []
  https_keypairs_reload_interval: 0s
  acme: {}",
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
    command => 'bash -c "teleport-update link-package 2>/dev/null || true; teleport-update enable"',
    user    => 'root',
    onlyif  => 'test -f /opt/teleport/system/bin/teleport-update',
    unless  => 'teleport-update status 2>&1 | grep -q "enabled: true"',
  }

  # DAG
  # Конфигурация → перезапуск сервиса
  File['/etc/teleport.yaml']
    ~> Service['teleport']

  # После запуска сервиса → включаем автообновления
  Service['teleport']
    -> Exec['teleport_enable_updates']

  # Rsyslog конфиг → перезапуск rsyslog
  File['/etc/rsyslog.d/13-teleport.conf']
    ~> Service['rsyslog']

}
