node 'ua-sm-poslutsk-01' {
  $ua_sm_fr = '2.0.0-hotfix.250'
  $ua_sm_sp = '0.1.14-alpha.31'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $checkbox = '1.6.13'
  $tele_env = 'ua-sm'
  $tele_group = 'restoran'
  $zbx_srv = 'zabbix6active.x100group.com:10051'
  $splunk_srv = 'splunk.x100group.com'
  $splunk_inx = 'jetti_ua'

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
  include splunk_conf
  include teleport
  include teleport::teleport_fix
  include teamviwer
  include ua_pw_change
}

node /(?i)^ru-gs-*/{
  $ru_gs_fr = '2.0.0-hotfix.248'
  $ru_gs_sp = '0.1.14-alpha.93'
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
  include vnc_soft
  include ru_pw_change
}

node /(?i)^ru-sm-*/{
  $ru_sm_fr = '2.0.0-hotfix.248'
  $ru_sm_sp = '0.1.14-alpha.93'
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
  include vnc_soft
  include ru_pw_change
}

node /(?i)^ua-mp-*/{
  $ua_mp_fr = '2.0.0-hotfix.250'
  $ua_mp_sp = '0.1.14-alpha.31'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $checkbox = '1.6.13'
  $tele_env = 'ua-mp'
  $tele_group = 'restoran'
  $zbx_srv = 'zabbix6active.x100group.com:10051'
  $splunk_srv = 'splunk.x100group.com'
  $splunk_inx = 'jetti_ua'

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
  include splunk_conf
  include teleport
  include teamviwer
  include ua_pw_change
}

node /(?i)^ua-sm-*/{
  $ua_sm_fr = '2.0.0-hotfix.250'
  $ua_sm_sp = '0.1.14-alpha.31'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $checkbox = '1.6.13'
  $tele_env = 'ua-sm'
  $tele_group = 'restoran'
  $zbx_srv = 'zabbix6active.x100group.com:10051'
  $splunk_srv = 'splunk.x100group.com'
  $splunk_inx = 'jetti_ua'

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
  include splunk_conf
  include teleport
  include teamviwer
  include ua_pw_change
}

node /(?i)^ua-pos-test*/{
  $ua_sm_fr = '2.0.0-hotfix.250'
  $ua_sm_sp = '0.1.12'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $checkbox = '1.4.22'
  $tele_env = 'ua-pos'
  $tele_group = 'tested'
  $zbx_srv = 'zabbix6active.x100group.com:10051'
  $splunk_srv = 'splunk.x100group.com'
  $splunk_inx = 'jetti_ua'

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
  include teleport
  include teamviwer
  include ua_pw_change
}

node /(?i)^ae-ck-*/{
  $ae_ck_fr = '2.0.0-hotfix.250'
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
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include zabbix
  include splunk

}

node /(?i)^kz-sm-*/{
  $kz_sm_fr = '2.0.0-hotfix.250'
  $kz_sm_sp = '0.1.12'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $tele_env = 'kz-sm'
  $tele_group = 'restoran'
  $zbx_srv = 'zabbix6active.x100group.com:10051'

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
  $by_sm_fr = '2.0.0-hotfix.248'
  $by_sm_sp = '0.1.12'
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
  include ru_pw_change
}

node /(?i)^hu-sm-*/{
  $hu_sm_fr = '2.0.0-hotfix.248'
  $hu_sm_sp = '0.1.14-alpha.31'
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
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include zabbix
  include splunk

}

node /(?i)^ru-ms-*/{
  $hu_sm_fr = '2.0.0-hotfix.248'
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
  include ru_pw_change
}

node /(?i)^us-sm-*/{
  $us_sm_fr = '2.0.0-hotfix.248'
  $us_sm_sp = '0.1.14-alpha.31'
  $tele_env = 'us-sm'
  $tele_group = 'restoran'
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
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include teleport
  include teleport::teleport_fix
  include zabbix
  include splunk
}

node 'default' {

}
