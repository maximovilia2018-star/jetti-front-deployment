class fiscal_ua_new(
    $versioncheckbox,
) {
  package { 'checkbox-kasa':
    ensure => "$versioncheckbox",
    name => 'checkbox-kasa',
  }

  file { '/usr/share/checkbox_kasa':
      ensure  => 'present',
      replace => 'no',
      owner => 'bit',
      group => 'bit',
      mode => '0644',
      require => Package['checkbox-kasa'],
  }

  exec { "checkbox-kasa-multiple":
    command => "/usr/bin/dpkg --configure -a && /usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold --force-yes install jetti-front=$version && reboot" ,
    user    => 'root',
    unless  => ["/bin/dpkg -s jetti-front | grep -oP \'Version: $version$\'", "/bin/bash /opt/precheck_before_update.sh ${version}"],
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
      VER=\$1
      status=\$(curl --location --request GET \"https://version-provider.x100-apps.com/api/getversion?environment=${environment}&posid=\$posid&psname=\$psname\" | jq -r \".readytoupdate\")
      if [ \$status = \"false\" ]; then
        # apt-get install --download-only -y checkbox-kasa=${versioncheckbox}
        exit 0
      else
        echo \"We can update\"
        kasafolders=\$(curl --location 'https://jetti-front-fn.azurewebsites.net/api/http-executor?code=MlpyWn8wsRS7tWqdhYq8S1aluLAm1xkUQY07ps6Buihpo2Dil0mXmA%3D%3D' \
        --header 'Content-Type: application/json' \
        --data '{
          \"args\": { \"posId\": \"\$posid\" },
          \"method\": \"cashShift.getPosState\"
          }' | jq \".result.fiscalSettings[].folderName\")
          for i in \"\${kasafolders[@]}\"
          do
            echo "\$i"
            if [\$i != \"checkbox_kasa\"]; then
              #rsync -av --progress /usr/share/checkbox_kasa /usr/share/\$i --exclude thefoldertoexclude --exclude anotherfoldertoexclude
            fi
          done
        exit 1
      fi
      exit 1
  fi
  exit 1",
      mode    => '0755',
   }

}
