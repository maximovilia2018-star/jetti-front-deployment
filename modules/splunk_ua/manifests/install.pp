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

  exec { 'splunk_download':
    command => "rm -f ${local_path}.tmp && wget -q -O ${local_path}.tmp ${splunk_url} && mv ${local_path}.tmp ${local_path}",
    creates => $local_path,
    unless  => $version_check,
    timeout => 600,
  }

  # Установка пакета через dpkg с автоматическим исправлением зависимостей
  exec { 'splunk_install':
    command => "dpkg -i ${local_path} || (apt-get -y -f install && dpkg -i ${local_path})",
    unless  => $version_check,
    require => Exec['splunk_download'],
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
  exec { 'splunk_enable_boot':
    command => '/opt/splunkforwarder/bin/splunk enable boot-start -user splunk --accept-license --answer-yes --no-prompt',
    creates => '/etc/init.d/splunk',
    require => Exec['splunk_install'],
  }

  # Сервис Splunk (управление только запуском, перезапуск через notify из config)
  service { 'splunk':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    require   => Exec['splunk_enable_boot'],
  }

}
