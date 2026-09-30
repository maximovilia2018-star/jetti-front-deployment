# ==============================================================================
# 1. ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ (TOP SCOPE)
# Значения по умолчанию для всей инфраструктуры
# ==============================================================================
$githubtoken            = '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'
$applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

# Базовые версии фронтендов по умолчанию
$ua_mp_fr = '2.0.0-hotfix.273'
$ua_sm_fr = '2.0.0-hotfix.273'
$ru_sm_fr = '2.0.0-hotfix.271'
$ae_ck_fr = '2.0.0-hotfix.273'
$kz_sm_fr = '2.0.0-hotfix.273'
$hu_sm_fr = '2.0.0-hotfix.273'
$us_sm_fr = '2.0.0-hotfix.271'

# Базовые версии спулеров по умолчанию
$ua_mp_sp = '0.1.14-alpha.31'
$ua_sm_sp = '0.1.14-alpha.31'
$ae_ck_sp = '0.1.12'
$kz_sm_sp = '0.1.14-alpha.25'
$hu_sm_sp = '0.1.14-alpha.31'
$us_sm_sp = '0.1.14-alpha.31'

# Чекбоксы по умолчанию
$checkbox = '1.7.5'

# ==============================================================================
# 2. ОПИСАНИЕ НОД (NODE SCOPES)
# ==============================================================================
node 'jf-tester-01' {
  # Токены и версии берутся из Global Scope автоматически
  # Временная строка отладки (выведет и глобальную, и локальные переменные)
  notice(">>> DEBUG: GLOBAL ua_mp_fr = ${::ua_mp_fr} | GLOBAL key = ${::applicationinsightskey} <<<")
  
  class {jetti_front:
    version        => "$ua_mp_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {aypiservis_front:
    version        => "$ru_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }

  include profile::ua
}

node /(?i)^ua-mp-*/{
  $tele_env = 'ua-mp'

  class {jetti_front:
    version => "$ua_mp_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {fiscal_ua:
    versioncheckbox => "$checkbox",
  }
  include profile::ua
}

node /(?i)^ua-sm-*/{
  $tele_env = 'ua-sm'

  class {jetti_front:
    version => "$ua_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {fiscal_ua:
    versioncheckbox => "$checkbox",
  }
  include profile::ua
}

node /(?i)^ua-pos-test.*/ {
#  $splunk_srv             = 'splunk.x100group.com'
  $splunk_var             = 'Jetti_VAR-site.pp'
  $tele_env               = 'ua-pos'
  $tele_grp               = 'tested'

  class { 'jetti_front':
    version        => $ua_sm_fr,
    appinsightskey => $applicationinsightskey,
  }
  class { 'fiscal_ua':
    versioncheckbox => $checkbox,
  }
  include profile::ua
  #include profile_base
  #include splunk
  #include splunk2
  #include teleport
  #include zabbix
  #include pw_ua_change
  #include teamviewer
}

node /(?i)^ae-ck-*/{
  $tele_env = 'ae-ck'

  class {jetti_front:
    version => "$ae_ck_fr",
    appinsightskey => "$applicationinsightskey",
  }
  include profile::ae
}

node /(?i)^kz-sm-*/{
  class {jetti_front:
    version => "$kz_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {jetti_front_fiscal_spooler:
    version => "$kz_sm_sp",
    githubtoken => "$githubtoken",
  }
  include profile::kz
}

node /(?i)^hu-sm-*/{
  $checkbox = '0.1.12'
  $tele_env = 'hu-sm'

  class {jetti_front:
    version => "$hu_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {jetti_front_fiscal_spooler:
    version => "$hu_sm_sp",
    githubtoken => "$githubtoken",
  }
  class {fiscal_ua:
    versioncheckbox => "$checkbox",
  }
  include profile
}

node /(?i)^us-sm-*/{
  $checkbox = '0.1.12'
  $tele_env = 'us-sm'

  class {jetti_front:
    version => "$us_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {jetti_front_fiscal_spooler:
    version => "$us_sm_sp",
    githubtoken => "$githubtoken",
  }
  class {fiscal_ua:
    versioncheckbox => "$checkbox",
  }
  include profile
}

node 'default' {

}
