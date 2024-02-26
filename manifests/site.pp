node /(?i)^ru-gs-*/{
  $ru_gs_fr = '2.0.0-hotfix.138'
  $ru_gs_sp = '0.1.14-alpha.37'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $zbx_srv = 'zabbix5.x100group.com:10049'

  class {jetti_front:
    version => "$ru_gs_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {jetti_front_fiscal_spooler:
    version => "$ru_gs_sp",
    githubtoken => "$githubtoken",
  }
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include zabbix
  include splunk

}

node /(?i)^ru-sm-*/{
  $ru_sm_fr = '2.0.0-hotfix.138'
  $ru_sm_sp = '0.1.14-alpha.37'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $zbx_srv = 'zabbix5.x100group.com:10049'

  class {jetti_front:
    version => "$ru_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {jetti_front_fiscal_spooler:
    version => "$ru_sm_sp",
    githubtoken => "$githubtoken",
  }
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include zabbix
  include splunk

}

node /(?i)^ua-mp-*/{
  $ua_mp_fr = '2.0.0-hotfix.138'
  $ua_mp_sp = '0.1.14-alpha.31'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $checkbox = '1.4.6'
  $tele_env = 'ua-mp'
  $tele_group = 'restoran'
  $zbx_srv = 'zabbix6active.x100group.com:10051'

  class {jetti_front:
    version => "$ua_mp_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {fiscal_ua_new:
    versioncheckbox => "$checkbox",
  }
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include zabbix
  include splunk
  include teleport
}

# node 'ua-sm-poskiev-21' {
#   $ua_sm_fr = '2.0.0-hotfix.138'
#   $ua_sm_sp = '0.1.14-alpha.31'
#   $githubtoken = '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'
#   $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
#   $checkbox = '1.1.40'
#   $tele_env = 'ua-sm'
#   $tele_group = 'restoran'
#   $zbx_srv = 'zabbix6active.x100group.com:10051'
#   class {jetti_front:
#     version => "$ua_sm_fr",
#     appinsightskey => "$applicationinsightskey",
#   }
#   class {fiscal_ua_new:
#     versioncheckbox => "$checkbox",
#   }
#   include base_soft
#   include log_config
#   include root_ca_cert
#   include swap_on
#   include zabbix
#   include splunk
#   include teleport
# }

node /(?i)^ua-sm-*/{
  $ua_sm_fr = '2.0.0-hotfix.138'
  $ua_sm_sp = '0.1.14-alpha.31'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $checkbox = '1.1.40'
  $tele_env = 'ua-sm'
  $tele_group = 'restoran'
  $zbx_srv = 'zabbix6active.x100group.com:10051'
  class {jetti_front:
    version => "$ua_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {fiscal_ua_new:
    versioncheckbox => "$checkbox",
  }
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include zabbix
  include splunk
  include teleport
}

node /(?i)^ua-pos-test*/{
  $ua_sm_fr = '2.0.0-hotfix.138'
  $ua_sm_sp = '0.1.14-alpha.31'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $checkbox = '1.1.40'
  $tele_env = 'ua-pos'
  $tele_group = 'tested'
  $zbx_srv = 'zabbix6active.x100group.com:10051'

  class {jetti_front:
    version => "$ua_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {fiscal_ua_new:
    versioncheckbox => "$checkbox",
  }
  include swap_on
  include base_soft
  include root_ca_cert
  include log_config
  include zabbix
  include splunk
}

node /(?i)^ae-ck-*/{
  $ae_ck_fr = '2.0.0-hotfix.138'
  $ae_ck_sp = '0.1.12'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

  class {jetti_front:
    version => "$ae_ck_fr",
    appinsightskey => "$applicationinsightskey",
  }
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include zabbix
  include splunk

}

node /(?i)^kz-sm-*/{
  $kz_sm_fr = '2.0.0-hotfix.138'
  $kz_sm_sp = '0.1.14-alpha.25'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $zbx_srv = 'zabbix5.x100group.com:10049'

  class {jetti_front:
    version => "$kz_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {jetti_front_fiscal_spooler:
    version => "$kz_sm_sp",
    githubtoken => "$githubtoken",
  }
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include zabbix
  include splunk

}

node /(?i)^by-sm-*/{
  $by_sm_fr = '2.0.0-hotfix.138'
  $by_sm_sp = '0.1.13-rc.2'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $zbx_srv = 'zabbix5.x100group.com:10049'

  class {jetti_front:
    version => "$by_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {jetti_front_fiscal_spooler:
    version => "$by_sm_sp",
    githubtoken => "$githubtoken",
  }
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include zabbix
  include splunk

}

node /(?i)^hu-sm-*/{
  $hu_sm_fr = '2.0.0-hotfix.138'
  $hu_sm_sp = '0.1.12'
  $checkbox = '1.1.40'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $zbx_srv = 'zabbix5.x100group.com:10049'

  class {jetti_front:
    version => "$hu_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {jetti_front_fiscal_spooler:
    version => "$hu_sm_sp",
    githubtoken => "$githubtoken",
  }
  class {fiscal_ua_new:
    versioncheckbox => "$checkbox",
  }
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include zabbix
  include splunk

}

node /(?i)^ru-ms-*/{
  $hu_sm_fr = '2.0.0-hotfix.138'
  $hu_sm_sp = '0.1.12'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $zbx_srv = 'zabbix5.x100group.com:10049'

  class {jetti_front:
    version => "$ru_ms_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {jetti_front_fiscal_spooler:
    version => "$ru_ms_sp",
    githubtoken => "$githubtoken",
  }
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include zabbix
  include splunk

}

node 'default' {

}
