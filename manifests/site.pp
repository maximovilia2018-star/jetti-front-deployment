node 'ua-sm-poskamenskoe-03' {
  $ua_sm_fr = '2.0.0-hotfix.273'
  $ua_sm_sp = '0.1.14-alpha.31'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $checkbox = '1.7.5'
  $tele_ver = '15'
  $tele_env = 'ua-sm'

  class {jetti_front:
    version => "$ua_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {fiscal_ua_new:
    versioncheckbox => "$checkbox",
  }
#  include profile::ua
  include profile::base
  include profile::timezone_ua
  include profile::ua_pw_change

  include splunk
  #include teleport
  include teamviewer
  class { 'zabbix':
    zabbix_srv => "$zbx_srv",
  }

  #include teleport::keyring_gpg
  #include teleport::teleport_one_time_fix
  #include teleport
  #include teleport::teleport_inst
  #include teleport::teleport_config
  
}

node /(?i)^ua-mp-*/{
  $ua_mp_fr = '2.0.0-hotfix.273'
  $ua_mp_sp = '0.1.14-alpha.31'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $checkbox = '1.7.5'
  $tele_env = 'ua-mp'

  class {jetti_front:
    version => "$ua_mp_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {fiscal_ua_new:
    versioncheckbox => "$checkbox",
  }
  include profile::ua
}

node /(?i)^ua-sm-*/{
  $ua_sm_fr = '2.0.0-hotfix.273'
  $ua_sm_sp = '0.1.14-alpha.31'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $checkbox = '1.7.5'
  $tele_env = 'ua-sm'

  class {jetti_front:
    version => "$ua_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {fiscal_ua_new:
    versioncheckbox => "$checkbox",
  }
  include profile::ua
}

node /(?i)^ua-pos-test*/{
  $ua_sm_fr = '2.0.0-hotfix.273'
  $ua_sm_sp = '0.1.14-alpha.31'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $checkbox = '1.7.5'
  $tele_env = 'ua-pos'
  $tele_group = 'tested'

  class {jetti_front:
    version => "$ua_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {fiscal_ua_new:
    versioncheckbox => "$checkbox",
  }
  include profile::ua
}

node /(?i)^ae-ck-*/{
  $ae_ck_fr = '2.0.0-hotfix.271'
  $ae_ck_sp = '0.1.12'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $tele_env = 'ae-ck'

  class {jetti_front:
    version => "$ae_ck_fr",
    appinsightskey => "$applicationinsightskey",
  }
  include profile::ae
}

node /(?i)^hu-sm-*/{
  $hu_sm_fr = '2.0.0-hotfix.271'
  $hu_sm_sp = '0.1.14-alpha.31'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $tele_env = 'hu-sm'

  class {jetti_front:
    version => "$hu_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  #class {jetti_front_fiscal_spooler:
  #  version => "$hu_sm_sp",
  #  githubtoken => "$githubtoken",
  #}
  include profile::hu
}

node /(?i)^us-sm-*/{
  $us_sm_fr = '2.0.0-hotfix.271'
  $us_sm_sp = '0.1.14-alpha.31'
  $tele_env = 'us-sm'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

  class {jetti_front:
    version => "$us_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
#  class {jetti_front_fiscal_spooler:
#    version => "$us_sm_sp",
#    githubtoken => "$githubtoken",
#  }
  include profile
}

node 'default' {
}
