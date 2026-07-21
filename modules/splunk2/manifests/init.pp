# modules/splunk2/manifests/init.pp
# Тест передачи параметров
class splunk2 {
  # Перебираем: локальный scope -> scope ноды -> жесткий дефолт
  $var = pick($splunk_var, $::splunk_var, 'Jetti_VAR-init.pp')
  $tst = pick($splunk_tst, $::splunk_tst, 'Jetti_TST-init.pp')

  class { 'splunk2::config':
    int_var => $var, # Передаем локальный $var в параметр int_var класса config
    int_tst => $tst,
  }
}
