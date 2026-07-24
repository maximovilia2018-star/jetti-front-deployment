# modules/jetti_front/manifests/init.pp
#
# Установка и обновление Jetti Front.
#
# Puppet отвечает только за инфраструктуру:
#  - контроль требуемой версии (noop)
#  - доставка файлов
#  - доставка репозитория
#  - настройка sudo
#  - запуск скрипта обновления
#
# Вся логика обновления находится в update-jetti-front.sh
class jetti_front (
    $version,
    $appinsightskey,
) {

  $update_script = '/usr/local/bin/update-jetti-front.sh'

  file { "/etc/environment":
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "PATH=\"/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin\"
ENV=\"${environment}\"
INSTRUMENTATION_KEY=${$appinsightskey}",
  }

  # Отключение автообновления через 'apt upgrade'
  file { '/etc/apt/preferences.d/jetti-front.pref':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/jetti_front/jetti-front.pref',
  }

  # Контроль требуемой версии
  package { 'jetti-front':
    ensure => $version,
    noop   => true,
  }

  # Репозиторий X100
  file { '/etc/apt/sources.list.d/x100.list':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/jetti_front/x100.list',
  }

  # Автозагрузка для пользователя bit
  file { '/home/bit/.config/autostart/x100-front.desktop':
    ensure  => file,
    owner   => 'bit',
    group   => 'bit',
    mode    => '0644',
    source  => 'puppet:///modules/jetti_front/x100-front.desktop',
  }

  # Конфигурация logrotate для обслуживания журнала обновления
  file { '/etc/logrotate.d/jetti-front':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => 'puppet:///modules/jetti_front/jetti-front.logrotate',
  }

  # Скрипт обновления
  file { $update_script:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/jetti_front/update-jetti-front.sh',
  }

  # Скрипт установки (через приложение)
  file { '/opt/install-front.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => 'puppet:///modules/jetti_front/install-front.sh',
  }

  # Sudo для скрипта установки (через приложение)
  class { 'sudo':
    config_file_replace => false,
  }

  sudo::conf { 'bit':
    priority => 10,
    content  => 'bit ALL= NOPASSWD: /opt/install-front.sh',
  }

  # Запуск обновления (если версия не соответствует)
  exec { 'update_jetti_front':
    command   => "${update_script} ${version}",
    path      => ['/usr/local/bin', '/usr/bin', '/usr/sbin'],
    unless => "[ \"\$(/usr/bin/dpkg-query -W -f='\${Version}' jetti-front 2>/dev/null)\" = '${version}' ]",
    require => File[$update_script],
    logoutput => on_failure,
    timeout => 1500,
  }

}
