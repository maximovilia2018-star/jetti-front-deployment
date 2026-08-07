# modules/teleport/manifests/recovery.pp
#
# Проверяет состояние Teleport и выполняет восстановление при необходимости.
# Генерирует событие run_teleport_recovery для принудительной переустановки.

class teleport::recovery (
  String $target_version,
) {

  # Скрипт проверки состояния Teleport
  file { '/usr/local/bin/teleport-check.sh':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/teleport/teleport-check.sh',
  }

  # Скрипт восстановления Teleport (destructive)
  file { '/usr/local/bin/teleport-recovery.sh':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/teleport/teleport-recovery.sh',
  }

  # Предварительная проверка состояния Teleport.
  # Скрипт возвращает 0 если требуется восстановление, иначе 1.
  # Puppet требует command для Exec, поэтому используется no-op /bin/true.
  # Реальная логика принятия решения находится в onlyif (teleport-check.sh).
  exec { 'teleport_precheck':
    command => '/bin/true',
    onlyif  => "/usr/local/bin/teleport-check.sh ${target_version}",
  }

  # Восстановление Teleport: выполняется только если precheck вернул 0.
  # Скрипт полностью очищает систему перед переустановкой.
  exec { 'run_teleport_recovery':
    command     => "/usr/local/bin/teleport-recovery.sh ${target_version}",
    cwd         => '/',
    path        => ['/bin', '/usr/bin', '/usr/local/bin'],
    user        => 'root',
    refreshonly => true,
    timeout     => 300,
  }

  # Скрипт проверки → проверка → восстановление
  File['/usr/local/bin/teleport-check.sh']
    -> Exec['teleport_precheck']
    ~> Exec['run_teleport_recovery']

  # Скрипт восстановления → восстановление
  File['/usr/local/bin/teleport-recovery.sh']
    -> Exec['run_teleport_recovery']

}
