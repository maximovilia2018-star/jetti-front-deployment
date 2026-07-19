# modules/splunk/manifests/init.pp
#
# Устанавливает и настраивает Splunk Universal Forwarder.
class splunk {
  # Установка Splunk Forwarder
  include splunk::install

  # Настройка Splunk Forwarder
  class { 'splunk::config':
    splunk_srv => $splunk_srv,
    splunk_inx => $splunk_inx,
  }

}
