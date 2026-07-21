node /(?i)^ru-gs-*/{
  $ru_gs_fr = '2.0.0-hotfix.271'
  $ru_gs_sp = '0.1.14-alpha.91'
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
  include profile_base
  #include zabbix
  #include splunk
  include pw_ru_change
}

node /(?i)^ru-sm-*/{
  $ru_sm_fr = '2.0.0-hotfix.271'
  $ru_sm_sp = '0.1.14-alpha.91'
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
  include profile_base
  #include zabbix
  #include splunk
  include pw_ru_change
}

node /(?i)^ua-mp-*/{
  $ua_mp_fr = '2.0.0-hotfix.273'
  $ua_mp_sp = '0.1.14-alpha.31'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $checkbox = '1.7.5'
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
  include profile_base
  #include zabbix
  #include splunk
  #include teleport
  #include teamviewer
  include pw_ua_change
}

node /(?i)^ua-sm-*/{
  $ua_sm_fr = '2.0.0-hotfix.273'
  $ua_sm_sp = '0.1.14-alpha.31'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $checkbox = '1.7.5'
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
  include profile_base
  #include zabbix
  #include splunk
  #include teleport
  #include teamviewer
  include pw_ua_change
}

node /(?i)^ua-pos-test.*/ {
  $ua_sm_fr               = '2.0.0-hotfix.273'
  $ua_sm_sp               = '0.1.14-alpha.31'
  $checkbox               = '1.7.5'
  $githubtoken            = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $zbx_srv                = 'zabbix6active.x100group.com:10051'
  $splunk_srv             = 'splunk.x100group.com'
  $splunk_inx             = 'jetti_ua'
  $splunk_var             = 'Jetti_VAR-site.pp'
  $tele_env               = 'ua-pos'
  $tele_grp               = 'tested'

  class { 'jetti_front':
    version        => $ua_sm_fr,
    appinsightskey => $applicationinsightskey,
  }
  #class { 'fiscal_ua_new':
  #  versioncheckbox => $checkbox,
  #}
  include profile_base
  include splunk
  include splunk2
  include teleport
  include zabbix
  include pw_ua_change
  include teamviewer
}

node /(?i)^ae-ck-*/{
  $ae_ck_fr = '2.0.0-hotfix.273'
  $ae_ck_sp = '0.1.12'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $tele_env = 'ae-ck'
  $tele_group = 'restoran'
  $zbx_srv = 'zabbix6active.x100group.com:10051'

  class {jetti_front:
    version => "$ae_ck_fr",
    appinsightskey => "$applicationinsightskey",
  }
  include profile_base
  #include zabbix
  #include splunk
  include vnc_soft
}

node /(?i)^kz-sm-*/{
  $kz_sm_fr = '2.0.0-hotfix.273'
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
  include profile_base
  #include zabbix
  #include splunk
}

node /(?i)^by-sm-*/{
  $by_sm_fr = '2.0.0-hotfix.271'
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
  include profile_base
  #include zabbix
  #include splunk
  include pw_ru_change
}

node /(?i)^hu-sm-*/{
  $hu_sm_fr = '2.0.0-hotfix.273'
  $hu_sm_sp = '0.1.14-alpha.31'
  $checkbox = '0.1.12'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $tele_env = 'hu-sm'
  $tele_group = 'restoran'
  $zbx_srv = 'zabbix6active.x100group.com:10051'

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
  include profile_base
  #include zabbix
  #include splunk
}

node /(?i)^ru-ms-*/{
  $hu_sm_fr = '2.0.0-hotfix.273'
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
  include profile_base
  #include zabbix
  #include splunk
}

node /(?i)^us-sm-*/{
  $us_sm_fr = '2.0.0-hotfix.271'
  $us_sm_sp = '0.1.14-alpha.31'
  $checkbox = '0.1.12'
  $tele_env = 'us-sm'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $zbx_srv = 'zabbix6active.x100group.com:10051'

  class {jetti_front:
    version => "$us_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {jetti_front_fiscal_spooler:
    version => "$us_sm_sp",
    githubtoken => "$githubtoken",
  }
  class {fiscal_ua_new:
    versioncheckbox => "$checkbox",
  }
  include profile_base
  #include teleport
  #include zabbix
  #include splunk
}

node 'default' {

}
