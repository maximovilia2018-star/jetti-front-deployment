# modules/teleport/manifests/init.pp
#
# Устанавливает и настраивает Teleport на POS-терминалах.
# Состоит из трех этапов:
# 1. teleport::recovery - проверка и восстановление (при необходимости)
# 2. teleport::install - установка пакета Teleport
# 3. teleport::config - настройка конфигурации Teleport

class teleport (
  String $version = pick($teleport_version, '16'),
){

  # Проверка и восстановление Teleport (при необходимости)
  class { 'teleport::recovery':
    target_version => $version,
  }

  # Установка Teleport
  class { 'teleport::install':
    install_version => $version,
  }

  # Настройка конфигурации Teleport
  class { 'teleport::config':
    #tele_env   => $tele_env,
    #tele_group => $tele_group,
  }

  # Четкая цепочка зависимостей
  Class['teleport::recovery']
    -> Class['teleport::install']
    -> Class['teleport::config']

}
