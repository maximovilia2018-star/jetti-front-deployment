# ===================================
# ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ (TOP SCOPE)
# ===================================
$githubtoken            = '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'
$applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

# Базовые версии фронтендов по умолчанию
$ua_mp_fr = '2.0.0-hotfix.273'
$ua_sm_fr = '2.0.0-hotfix.273'
$ae_ck_fr = '2.0.0-hotfix.271'
$hu_sm_fr = '2.0.0-hotfix.271'
$us_sm_fr = '2.0.0-hotfix.271'

# Базовые версии спулеров по умолчанию
$ua_mp_sp = '0.1.14-alpha.32'
$ua_sm_sp = '0.1.14-alpha.32'
$ae_ck_sp = '0.1.12'
$hu_sm_sp = '0.1.14-alpha.31'
$us_sm_sp = '0.1.14-alpha.31'

# Чекбоксы по умолчанию
$checkbox = '1.7.5'

# ===================================
# ОПИСАНИЕ НОД (NODE SCOPES)
# ===================================
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

node /(?i)^ua-pos-test*/{
  $tele_env = 'ua-pos'
  $tele_group = 'tested'
  class {jetti_front:
    version => "$ua_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {fiscal_ua:
    versioncheckbox => "$checkbox",
  }
  include profile::ua
}

node /(?i)^ae-ck-*/{
  $tele_env = 'ae-ck'
  class {jetti_front:
    version => "$ae_ck_fr",
    appinsightskey => "$applicationinsightskey",
  }
  include profile::ae
}

node /(?i)^hu-sm-*/{
  $tele_env = 'hu-sm'
  class {jetti_front:
    version => "$hu_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  include profile::hu
}

node /(?i)^us-sm-*/{
  $tele_env = 'us-sm'
  class {jetti_front:
    version => "$us_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  include profile
}

node 'default' {
}
