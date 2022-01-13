class jetti_front {

  file { '/etc/apt/sources.list.d/x100.list':
      ensure  => 'present',
      replace => 'no',
      content => 'deb [trusted=yes] https://repository.jfd-prod.x100platforma.com/artifactory/debian x100 front',
      mode    => '0644',
  }

  file { '/home/bit/.config/autostart/x100-front.desktop':
      ensure  => 'present',
      replace => 'yes',
      content => '[Desktop Entry]
Type=Application
Encoding=UTF-8
Name=CashDesk
Comment=Cash Desk Sushi Master
Exec=jetti-front
Hidden=false
NoDisplay=false
Terminal=false',
      mode    => '0644',
  }

  exec { 'apt-get-update':
    command => "apt-get install ca-certificates && apt-get update || true",
    onlyif  => "wget -q -N -P /tmp https://repository.jfd-prod.x100platforma.com:443/artifactory/debian/dists/x100/Release && ! cmp -s /tmp/Release /var/lib/apt/lists/repository.jfd-prod.x100platforma.com_artifactory_debian_dists_x100_Release",
    path    => [ '/usr/bin', '/bin' ],
  }

  file { '/opt/intall-front.sh':
    ensure  => 'present',
    mode    => '0755',
    replace => 'yes',
    content => "#!/bin/bash
  VER=\$1
  /usr/bin/apt-get -q -y install jetti-front=\$VER && reboot
    ",
   }

   file { '/etc/sudoers':
     ensure  => 'present',
     replace => 'yes',
     content => '#
# This file MUST be edited with the 'visudo' command as root.
#
# Please consider adding local content in /etc/sudoers.d/ instead of
# directly modifying this file.
#
# See the man page for details on how to write a sudoers file.
#
Defaults	env_reset
Defaults	mail_badpass
Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"

# Host alias specification

# User alias specification

# Cmnd alias specification

# User privilege specification
root	ALL=(ALL:ALL) ALL
bit   ALL= NOPASSWD: /opt/intall-front.sh
# Members of the admin group may gain root privileges
%admin ALL=(ALL) ALL

# Allow members of group sudo to execute any command
%sudo	ALL=(ALL:ALL) ALL

     ',
    }


  file { '/opt/precheck_before_update.sh':
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
        apt-get install --download-only -y jetti-front=\$VER
        exit 0
      else
        echo \"We can update\"
        exit 1
      fi
      exit 1
  fi
  exit 1",
      mode    => '0755',
   }

}
