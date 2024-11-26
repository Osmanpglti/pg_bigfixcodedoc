class pg_bigfix (                 # pg_bigfix class created
  String $cloud_installer_path,   # Variable cloud_installer_path being called 
  String $installer_name,         # Variable Installer_name being called
  String $package_name,           # Variable package_name being called
  String $service_name,           # Variable service_name being called

  # Optional
  Boolean $exclude_module = false,      # Boolean condition false for exclude_module
  Boolean $exclude_module_except_tags = false,  # Boolean condition false for exclude_module_except_tags
) {
  if (!$pg_bigfix::exclude_module) { # Condition applied for pg_bigfix 
    if $facts['pg_platform'] == 'vmware' {  # condition to check pg_platform
      contain pg_bigfix::install  # condition is to check if pg_bigfix is install
      contain pg_bigfix::service # condition is to check if pg_bigfix service is started
      Class['Pg_bigfix::install'] -> Class['Pg_bigfix::service']  # install and service condition validating
    }
    elsif (!$pg_bigfix::exclude_module) and (!$pg_bigfix::exclude_module_except_tags) {  # ifelse conditions being applied for exclude_module and exclude_module_except_tags
      contain pg_bigfix::install # pg_bigfix called for install
      contain pg_bigfix::tags  # pg_bigfix called for tagging
      contain pg_bigfix::service # pg_bigfix called to start the service
      Class['Pg_bigfix::install'] ~> Class['Pg_bigfix::service'] # pg_bigfix is called for installation and service start
    } 
    elsif $pg_bigfix::exclude_module_except_tags { # ifelse condition for pg_bigfix for exclude_module_except_tags
      contain pg_bigfix::tags  # pg_bigfix called for tagging
    }
    else {}
  }
  else {}
}