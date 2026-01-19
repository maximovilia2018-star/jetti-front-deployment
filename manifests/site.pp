node /(?i)^ru-gs-*/{
  $ru_gs_fr = '2.0.0-hotfix.255'
  $ru_gs_sp = '0.1.14-alpha.91'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $zbx_srv = 'zabbix5.x100group.com:10049'

  class {aypiservis_front:
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
  include ru_pw_change
}

node /(?i)^ru-sm-*/{
  $ru_sm_fr = '2.0.0-hotfix.255'
  $ru_sm_sp = '0.1.14-alpha.91'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $zbx_srv = 'zabbix5.x100group.com:10049'

  class {aypiservis_front:
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
  include ru_pw_change
}
  
node /(?i)^ru-ms-*/{
  $hu_sm_fr = '2.0.0-hotfix.231'
  $hu_sm_sp = '0.1.12'
  $githubtoken = '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'
  $applicationinsightskey = '90b61832-cd0d-4d7f-b6dd-b539a6b0f8c9'
  $zbx_srv = 'zabbix5.x100group.com:10049'

  class {aypiservis_front:
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
