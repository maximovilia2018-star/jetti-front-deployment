#modules/fiscal_ua/manifests/init.pp
class fiscal_ua (
  $versioncheckbox,
) {
  require profile::nexus_repo
  $decrypt_tool  = '/usr/local/bin/decrypt-pos'
  $check_script  = '/usr/local/bin/check-count.sh'
  $sync_script   = '/usr/local/bin/sync-checkbox_kasa.sh'
  $update_script = '/usr/local/bin/update-checkbox_kasa.sh'

  # Ресурс пакета - только для информирования, реальное управление через скрипт
  package { 'checkbox-kasa':
    ensure => installed,
    noop   => true,
  }

  # Отключение автообновления через apt upgrade
  file { '/etc/apt/preferences.d/checkbox-kasa.pref':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source => 'puppet:///modules/fiscal_ua/checkbox-kasa.pref',
  }

  file { '/etc/apt/preferences.d/jetti-front-fiscal-spooler.pref':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source => 'puppet:///modules/fiscal_ua/jetti-front-fiscal-spooler.pref',
  }

  # Синхронизируем скрипт проверки
  file { $check_script:
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/fiscal_ua/check-count.sh',
  }

  # Синхронизируем скрипт синхронизации
  file { $sync_script:
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/fiscal_ua/sync-checkbox_kasa.sh',
  }

  # Синхронизируем скрипт обновления
  file { $update_script:
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/fiscal_ua/update-checkbox_kasa.sh',
  }

  # Синхронизируем бинарную утилиту дешифрования
  file { $decrypt_tool:
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
    source => 'puppet:///modules/fiscal_ua/decrypt-pos',
  }

  # Конфигурация logrotate для обслуживания журнала обновления касс
  file { '/etc/logrotate.d/checkbox-kasa':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source => 'puppet:///modules/fiscal_ua/checkbox-kasa.logrotate',
  }

  # Синхронизируем количество касс с данными АПИ
  exec { 'sync_checkbox_kasa':
    command => $sync_script,
    path    => ['/usr/local/bin', '/usr/bin', '/usr/sbin', '/bin'],
    unless  => $check_script,
    require => [
      File[$sync_script],
      File[$check_script],
    ],
  }

  # Обновляем, если версии не совпадают
  exec { 'update_checkbox_kasa':
    command => "${update_script} ${versioncheckbox}",
    path    => ['/usr/local/bin','/usr/bin','/usr/sbin','/bin'],
    unless  => "[ \"\$(/usr/bin/dpkg-query -W -f='\${Version}' checkbox-kasa 2>/dev/null)\" = '${versioncheckbox}' ]",
    require => File[$update_script],
  }
}
