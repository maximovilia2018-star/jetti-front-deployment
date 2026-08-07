# modules/teleport/manifests/keyring_gpg.pp
#
# Копирует GPG-ключ Teleport из локальных файлов модуля,
# если его нет на целевом хосте.
class teleport::keyring_gpg {

  file { '/usr/share/keyrings/teleport-archive-keyring.gpg':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    # Путь к файлу внутри вашего модуля
    source => 'puppet:///modules/teleport/teleport-archive-keyring.gpg',
  }

}
