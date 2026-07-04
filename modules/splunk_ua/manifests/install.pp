# modules/splunk_ua/manifests/install.pp
#
# Установка Splunk Universal Forwarder из официального deb-пакета.
# Поддерживаемая версия: 8.2.2
# Оптимизировано строго для Ubuntu 20.04 / 22.04.

class splunk_ua::install (
  Enum['8.2.2'] $splunk_version = '8.2.2',
) {

  # Resource defaults для всех exec в этом классе
  Exec {
    path => ['/usr/bin', '/bin', '/usr/sbin', '/sbin'],
  }

  $splunk_build = '87344edfcdb4'
  $splunk_deb   = "splunkforwarder-${splunk_version}-${splunk_build}-linux-2.6-amd64.deb"
  $splunk_url   = "https://download.splunk.com/products/universalforwarder/releases/${splunk_version}/linux/${splunk_deb}"
  $local_path   = "/var/tmp/${splunk_deb}"

  # Единая проверка установленной версии
  $version_check = "test \"\$(dpkg-query -W -f='\${Version}' splunkforwarder 2>/dev/null)\" = '${splunk_version}'"

  # Скачиваем пакет, ТОЛЬКО если нужная версия не установлена
  exec { 'splunk_download':
    command => "rm -f ${local_path}.tmp && wget -q -O ${local_path}.tmp ${splunk_url} && mv ${local_path}.tmp ${local_path}",
    unless  => $version_check,
    timeout => 600,
  }

  # Установка пакета через dpkg с автоматическим исправлением зависимостей
  # apt-get вызывается ТОЛЬКО при ошибке dpkg (экономия времени)
  exec { 'splunk_install':
    command => "dpkg -i ${local_path} || (apt-get -y -f install && dpkg -i ${local_path})",
    unless  => $version_check,
  }

  # Удаление deb-пакета и временного файла
  file {
    [
      $local_path,
      "${local_path}.tmp",
    ]:
      ensure  => absent,
      require => Exec['splunk_install'],
  }

  # Принятие лицензии и создание автозапуска
  # Splunk enable boot-start создает /etc/init.d/splunk
  exec { 'splunk_enable_boot':
    command => '/opt/splunkforwarder/bin/splunk enable boot-start -user splunk --accept-license --answer-yes --no-prompt',
    creates => '/etc/init.d/splunk',
  }

  # Сервис Splunk (имя: splunk) systemd генерирует splunk.service из /etc/init.d/splunk
  service { 'splunk':
    ensure    => running,
    enable    => true,
    hasstatus => true,
  }

  # DAG
  Exec['splunk_download']
    -> Exec['splunk_install']
    -> Exec['splunk_enable_boot']
    -> Service['splunk']

  Exec['splunk_install']
    -> File[
      $local_path,
      "${local_path}.tmp",
    ]

}
