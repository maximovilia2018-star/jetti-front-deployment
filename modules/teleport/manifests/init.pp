# modules/teleport/manifests/init.pp
#
# Устанавливает и настраивает Teleport на POS-терминалах.
# Состоит из трех этапов:
# 1. teleport::recovery - проверка и восстановление (при необходимости)
# 2. teleport::install - установка пакета Teleport
# 3. teleport::config - настройка конфигурации Teleport
class teleport {
  # Перебираем: локальный scope -> scope ноды -> жесткий дефолт
  #$tele_ver = pick($tele_ver, $::tele_ver, '16')
  #$tele_env = pick($tele_env, $::tele_env, 'ua-pos')
  #$tele_grp = pick($tele_grp, $::tele_grp, 'restoran')
  # Это заставляет Puppet 7 и 8 искать переменную напрямую в блоке node в site.pp
  #$tele_ver = pick(getvar('::tele_ver'), '16')
  #$tele_env = pick(getvar('::tele_env'), 'ua-pos')
  #$tele_grp = pick(getvar('::tele_grp'), 'restoran')

  $tele_ver = pick(getvar('tele_ver'), '16')
  $tele_env = pick(getvar('tele_env'), 'ua-pos')
  $tele_grp = pick(getvar('tele_grp'), 'restoran')


  # Проверка и восстановление Teleport (при необходимости)
  class { 'teleport::recovery':
    target_version => $tele_ver,
  }

  # Установка Teleport
  class { 'teleport::install':
    install_version => $tele_ver,
  }

  # Настройка конфигурации Teleport
  class { 'teleport::config': 
    tele_env => $tele_env,
    tele_grp => $tele_grp,
  }

  # Четкая цепочка зависимостей
  Class['teleport::recovery']
    -> Class['teleport::install']
    -> Class['teleport::config']

}
