# modules/splunk_ua/manifests/init.pp
#
# Устанавливает и настраивает Splunk Universal Forwarder.
class splunk (
#  String $splunk_srv = pick($facts['splunk_srv'], 'splunk.x100group.comn'),
#  String $splunk_inx = pick($facts['splunk_inx'], 'jetti_ua3'),
#  String $splunk_srv = 'splunk.x100group.comn33',
#  String $splunk_inx = 'jetti_ua33',
  String $splunk_srv,
  String $splunk_inx,
) {
  # Установка Splunk Forwarder
  include splunk::install
  # Настройка Splunk Forwarder
  class { 'splunk::config':
    splunk_srv => $splunk_srv,
    splunk_inx => $splunk_inx,
  }

}
