class base_soft {
  package { [ 'unattended-upgrades', 'bit-cash-box', ]:
    ensure => purged,
  }

  $required_tools = [
    'jq',      # Работа с JSON
    'curl',    # HTTP-запросы
    'wget',    # Загрузка файлов
    'mc',      # Midnight Commander
    'htop',    # Мониторинг процессов
    'gnupg',   # GPG-ключи (нужен для teamviewer и других репозиториев)
  ]

  package { $required_tools:
    ensure  => present,
    require => Package['unattended-upgrades'],
  }
}
