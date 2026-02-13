class zabbix {
  #include zabbix::pip_requirements
  #include zabbix::zabbix_agent
  #include zabbix::zabbix_config
  
  case $facts['os']['release']['major'] {
    '24.04': {
      # Для Ubuntu 24 используем новый манифест
      include zabbix::zabbix_agent_ubuntu24
    }
    default: {
      # Для всех остальных (20.04, 22.04 и т.д.) используем старый проверенный
      include zabbix::zabbix_agent
    }
  }
  
  # Конфиг одинаков для всех версий
  include zabbix::zabbix_config
}
