# modules/splunk2/manifests/config.pp
class splunk2::config (
  String $int_var,
  String $int_tst,
) {
  notify { 'init':
    message => @("EOF")

index0 - ${int_var}
index2 = ${int_tst}
| EOF
  }
}
