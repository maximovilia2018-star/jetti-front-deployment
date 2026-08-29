# modules/teamviewer/manifests/info.pp
#
# Манифест для разового сбора TeamViewer ID с конкретного хоста.
# Выводит информацию прямо в отчет (Notice) агента Puppet.
class teamviewer::info {

  # Выполняем команду на стороне клиента
  exec { 'show_teamviewer_id_in_report':
    command   => "/usr/bin/teamviewer info 2>/dev/null | /bin/grep -i 'TeamViewer ID'",
    path      => ['/usr/bin', '/bin', '/usr/sbin'],
    # logoutput => true заставляет Puppet скопировать вывод консоли в свой отчет
    logoutput => true,
    # refreshonly => false заставит команду выполняться КАЖДЫЙ РАЗ,
    # когда включен этот манифест, чтобы вы всегда видели актуальный ID
    refreshonly => false,
  }

}
