# modules/splunk_ua/manifests/init.pp
#
# Устанавливает и настраивает Splunk Universal Forwarder.
class splunk (
  Optional[String] $splunk_srv = undef,
  Optional[String] $splunk_inx = undef,
) {
  $srv = $splunk_srv ? {
    undef   => 'splunk.x100group.comn',
    default => $splunk_srv,
  }
  
  $inx = $splunk_inx ? {
    undef   => 'jetti_ua',
    default => $splunk_inx,
  }

  include splunk::install
  class { 'splunk::config':
    splunk_srv => $srv,
    splunk_inx => $inx,
  }
}
