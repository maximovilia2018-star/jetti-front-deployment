class fiscal_ua_new(
    $versioncheckbox,
){
  package { 'checkbox-kasa-new':
    ensure => "$versioncheckbox",
    name => 'checkbox-kasa',
    noop => true,
  }

  file { '/usr/share/checkbox_kasa':
      ensure  => 'present',
      replace => 'no',
      owner => 'bit',
      group => 'bit',
      mode => '0644',
      require => Package['checkbox-kasa-new'],
  }

  file { '/opt/checkbox_kasa_multiple.sh':
      ensure  => 'present',
      replace => 'yes',
      content => "#!/bin/bash
  FILE=/home/bit/.config/jetti-front/config.json
  if test -f \"\$FILE\"; then
      #echo \"\$FILE exists.\"
      posid=\$(jq -r \".posId\" \$FILE)
      psname=\$(hostname)
# --------  Проверка количества и создание/удаление каталогов для касс -----------
      C_PATH='/etc/checkbox_kasa'
      List=\$(curl -s --location --request POST 'https://jetti-front-fn.azurewebsites.net/api/http-executor?code=MlpyWn8wsRS7tWqdhYq8S1aluLAm1xkUQY07ps6Buihpo2Dil0mXmA%3D%3D'  --header 'Content-Type: application/json' --data '{\"args\": { \"posId\": \"'\"\$posid\"'\" },\"method\": \"cashShift.getPosState\"}' | jq -r \".result.fiscalSettings[].folderName\")
      for i in \$List
      do
        n=`echo \$i | awk -F \"_\" \'{print \$3+1}\'`
        conf_path=\"\$C_PATH/\$n/\"
        [ -d \$conf_path ] || ( mkdir -p \$conf_path; chown -R bit.bit \$conf_path; chmod -R 0755 \$conf_path )
      done
      if [[ \$List != \"\" ]]; then
        for (( i=\$n+1; i <= 5; i++ ))
          do
            conf_path=\"\$C_PATH/\$i/\"
            [ -d \$conf_path ] && ( rm -r \$conf_path )
          done
      fi
# ------------- Проверка версии и получение разрешения на обновление -------------
      installed_version=\$(dpkg-query -W -f=\'\${Version}\' checkbox-kasa 2>/dev/null || echo \"not_installed\")
      #echo \"Текущая версия: \$installed_version\"

      status=\$(curl -s --location --request GET \"https://version-provider.x100-apps.com/api/getversion?environment=${environment}&posid=\$posid&psname=\$psname\" | jq -r \".readytoupdate\")
      #--- Установка новой версии, если требуется ---
      if [[ \"\$installed_version\" != \"${versioncheckbox}\" && \"\$status\" == \"true\" ]]; then
        #echo \"Устанавливается новая версия checkbox-kasa ${versioncheckbox}\"
        /usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold -y --allow-downgrades install checkbox-kasa=\"${versioncheckbox}\"
        reboot
      fi
  fi
",
      mode    => '0755',
  }

  exec { "checkbox-kasa-multiple":
    #command => "/usr/bin/dpkg --configure -a && /usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold --force-yes install checkbox-kasa=$versioncheckbox && /bin/bash /opt/checkbox_kasa_multiple.sh && reboot" ,
    command => '/bin/bash /opt/checkbox_kasa_multiple.sh',
    user    => 'root',
    logoutput => 'true',
    unless  => ["/bin/bash /opt/checkbox_kasa_multiple.sh", "/bin/dpkg -s checkbox-kasa | grep -oP \'Version: $versioncheckbox$\'"],
    #refreshonly => false,  # Скрипт выполняется при каждом применении манифеста
  }

}
