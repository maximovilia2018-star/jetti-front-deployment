# modules/splunk/manifests/init.pp
#
# Устанавливает и настраивает Splunk Universal Forwarder.
class splunk {
  # Ищем переменную в scope ноды (site.pp) с помощью getvar().
  # Если её там не объявили, pick() сразу применит жесткий дефолт.
  $splunk_srv_real = pick(getvar('splunk_srv'), 'splunk.x100group.com')
  $splunk_inx_real = pick(getvar('splunk_inx'), 'jetti_ua')

  include splunk::install
  class { 'splunk::config':
    splunk_srv => $splunk_srv_real,
    splunk_inx => $splunk_inx_real,
  }
}
