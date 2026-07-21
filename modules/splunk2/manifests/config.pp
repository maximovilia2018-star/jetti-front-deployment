# modules/splunk2/manifests/config.pp
class splunk2::config (
  String $int_srv,
  String $int_inx,
  String $int_tst,
) {
  notify { 'init':
    message => @("EOF")

index0 - ${int_srv}
index1 = ${int_inx}
index2 = ${int_tst}
| EOF
  }
}
