# modules/splunk_ua/manifests/init.pp
#
# Устанавливает и настраивает Splunk Universal Forwarder.
class splunk {
  # Перебираем: локальный scope -> scope ноды -> жесткий дефолт
  $srv = pick($splunk_srv, $::splunk_srv, 'splunk.x100group.com')
  $inx = pick($splunk_inx, $::splunk_inx, 'jetti_ua')

  include splunk::install
  class { 'splunk::config':
    int_srv => $srv,
    int_inx => $inx,
  }
}
