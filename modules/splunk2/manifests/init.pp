# modules/splunk2/manifests/init.pp
# Тест передачи параметров
class splunk2 {
  # Перебираем: локальный scope -> scope ноды -> жесткий дефолт
  $srv = pick($splunk_srv, $::splunk_srv, 'Jetti_SRV-init.pp')
  $inx = pick($splunk_inx, $::splunk_inx, 'Jetti_INX-init.pp')
  $tst = pick($splunk_tst, $::splunk_tst, 'Jetti_TST-init.pp')

  class { 'splunk2::config':
    int_srv => $srv, # Передаем локальный $srv в параметр int_srv класса config
    int_inx => $inx,
    int_tst => $tst,
  }
}
