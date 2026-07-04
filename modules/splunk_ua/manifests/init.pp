# modules/splunk_ua/manifests/init.pp
#
# Устанавливает и настраивает Splunk Universal Forwarder.
# Поддерживаемые ОС: Ubuntu 20.04 / 22.04
# Версия Splunk берется из переменной $splunk_version в site.pp.
# По умолчанию: '8.2.2'

class splunk_ua (
  Enum['8.2.2'] $splunk_version = pick($::splunk_version, '8.2.2'),
  String        $splunk_srv     = pick($::splunk_srv, 'splunk.x100group.com'),
  String        $splunk_inx     = pick($::splunk_inx, 'jetti_ua'),
) {

  # Проверка поддерживаемой ОС
  if $facts['os']['name'] != 'Ubuntu' {
    fail("Unsupported OS: ${facts['os']['name']}. Only Ubuntu is supported.")
  }

  $release = $facts['os']['release']['full']

  unless $release =~ /^(20\.04|22\.04)/ {
    fail("Unsupported Ubuntu version: ${release}. Only Ubuntu 20.04 and 22.04 are supported.")
  }

  # Установка Splunk Forwarder
  class { 'splunk_ua::install':
    splunk_version => $splunk_version,
  }

  # Настройка Splunk Forwarder
  class { 'splunk_ua::config':
    splunk_srv => $splunk_srv,
    splunk_inx => $splunk_inx,
  }

  # Четкая цепочка зависимостей
  Class['splunk_ua::install']
    -> Class['splunk_ua::config']

}
