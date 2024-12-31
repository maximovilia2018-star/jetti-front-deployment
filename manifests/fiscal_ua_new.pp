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
      echo \"\$FILE exists.\"
      posid=\$(jq -r \".posId\" /home/bit/.config/jetti-front/config.json)
      psname=\$(hostname)
#--------------------------------------------------------------------------------
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
#--------------------------------------------------------------------------------
      status=\$(curl --location --request GET \"https://version-provider.x100-apps.com/api/getversion?environment=${environment}&posid=\$posid&psname=\$psname\" | jq -r \".readytoupdate\")
      if [ \$status = \"false\" ]; then
        #apt-get install --download-only -y checkbox-kasa=${versioncheckbox}
        exit 0
      else
        echo \"We can update\"
        for i in \$(curl --location --request POST 'https://jetti-front-fn.azurewebsites.net/api/http-executor?code=MlpyWn8wsRS7tWqdhYq8S1aluLAm1xkUQY07ps6Buihpo2Dil0mXmA%3D%3D'  --header 'Content-Type: application/json' --data '{\"args\": { \"posId\": \"'\"\$posid\"'\" },\"method\": \"cashShift.getPosState\"}' | jq -r \".result.fiscalSettings[].folderName\")
          do
            if [[ \$i != \"checkbox_kasa\" ]]; then
              echo \"------------------------\"
              echo \"\$i\"
              echo \"------------------------\"
              #rsync -av -p --progress /usr/share/checkbox_kasa/ /usr/share/\$i/ --exclude 'config.json' --exclude '*.db' --exclude '.secret.key' --exclude 'logs/' --exclude 'files_printer/'
              #chmod -R 0755 /usr/share/\$i
   	          #chown -R bit:bit /usr/share/\$i
            fi
          done
      fi
  fi
  exit 0",
      mode    => '0755',
  }

  exec { "checkbox-kasa-multiple":
    command => "/usr/bin/dpkg --configure -a && /usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold -y install checkbox-kasa=$versioncheckbox && /bin/bash /opt/checkbox_kasa_multiple.sh && reboot" ,
    user    => 'root',
    logoutput => 'true',
    unless  => ["/bin/bash /opt/checkbox_kasa_multiple.sh", "/bin/dpkg -s checkbox-kasa | grep -oP \'Version: $versioncheckbox$\'"],
  }

}
