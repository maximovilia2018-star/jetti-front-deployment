# modules/splunk_ua/manifests/init.pp
#
# Устанавливает и настраивает Splunk Universal Forwarder.
class splunk (
  String $splunk_srv = pick($::splunk_srv, 'splunk.x100group.com'),
  String $splunk_inx = pick($::splunk_inx, 'jetti_ua'),
  #String $splunk_srv,
  #String $splunk_inx,
) {
  # Установка Splunk Forwarder
  include splunk::install
  # Настройка Splunk Forwarder
  class { 'splunk::config':
    splunk_srv => $splunk_srv,
    splunk_inx => $splunk_inx,
  }

}
