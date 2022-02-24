node /(?i)^ru-gs-*/{
  $ru_gs_fr = '2.0.0~rc.12'
  $ru_gs_sp = '0.1.13-rc.2'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

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
  $ru_sm_fr = '2.0.0~rc.12'
  $ru_sm_sp = '0.1.13-rc.2'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

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
  $ua_mp_fr = '2.0.0~rc.12'
  $ua_mp_sp = '0.1.13-rc.2'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

  class {jetti_front:
    version => "$ua_mp_fr",
    appinsightskey => "$applicationinsightskey",
  }
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include zabbix
  include splunk
  include fiscal_ua
}

node /(?i)^ua-fm-*/{
  $ua_fm_fr = '2.0.0~rc.12'
  $ua_fm_sp = '0.1.12'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

  class {jetti_front:
    version => "$ua_fm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include zabbix
  include splunk
  include fiscal_ua
}

node /(?i)^ua-sm-*/{
  $ua_sm_fr = '2.0.0~rc.12'
  $ua_sm_sp = '0.1.13-rc.2'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

  class {jetti_front:
    version => "$ua_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include zabbix
  include splunk
  include fiscal_ua
}

node /(?i)^ua-pos-test*/{
  $ru_gs_fr = '2.0.0~rc.12'
  $ru_gs_sp = '0.1.13-rc.2'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

  class {jetti_front:
    version => "$ru_gs_fr",
    appinsightskey => "$applicationinsightskey",
  }
  class {jetti_front_fiscal_spooler:
    version => "$ru_gs_sp",
    githubtoken => "$githubtoken",
  }
  include swap_on
  include base_soft
  include root_ca_cert
  include log_config
  include zabbix
  include splunk

}

node /(?i)^by-sm-*/{
  $by_sm_fr = '2.0.0~rc.12'
  $by_sm_sp = '0.1.13-rc.2'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

  class {jetti_front:
    version => "$by_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include zabbix
  include splunk

}

node /(?i)^by-mp-*/{
  $by_mp_fr = '2.0.0~rc.13'
  $by_mp_sp = '0.1.12'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

  class {jetti_front:
    version => "$by_mp_fr",
    appinsightskey => "$applicationinsightskey",
  }
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include zabbix
  include splunk

}

node /(?i)^by-gs-*/{
  $by_gs_fr = '2.0.0~rc.12'
  $by_gs_sp = '0.1.12'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

  class {jetti_front:
    version => "$by_gs_fr",
    appinsightskey => "$applicationinsightskey",
  }
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include zabbix
  include splunk

}

node /(?i)^pl-sm-*/{
  $pl_sm_fr = '2.0.0~rc.12'
  $pl_sm_sp = '0.1.12'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

  class {jetti_front:
    version => "$pl_sm_fr",
    appinsightskey => "$applicationinsightskey",
  }
  include base_soft
  include log_config
  include root_ca_cert
  include swap_on
  include zabbix
  include splunk

}

node /(?i)^ae-sm-*/{
  $ae_sm_fr = '2.0.0~rc.12'
  $ae_sm_sp = '0.1.12'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'

  class {jetti_front:
    version => "$ae_sm_fr",
    appinsightskey => "$applicationinsightskey",
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
