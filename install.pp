class pg_bigfix::install {  # class pg_bigfix created for installation
  # Version does not exist or is empty = BigFix client is not installed
  if (!$facts['pg_bigfix']['version']) or ($facts['pg_bigfix']['version'] == '') {  # Version does not exist or is empty = BigFix client is not installed
    $_package_provider = $facts['os']['family'] ? { # by package_provider os being identified
      'RedHat'  => 'rpm', # it is mentioning the RPM command for Redhat 
      'Suse'    => 'rpm', # it is mentioning the RPM command for suse
      'Debian'  => 'dpkg', # it is mentioning the DPKG command forDebian
      'windows' => 'windows', # it is mentioning windows for windows 
      default   => fail("OS ${facts['os']['family']} is not supported"), # here code is identifying if os is supported or not 
    }

    $_puppet_masthead_path = $facts['pg_platform'].downcase ? { # puppet_masthead_path Variable defining for checking paths
      'vmware' => 'puppet:///modules/pg_bigfix/vmware-masthead', # variable define for Vmware path 
      'google' => 'puppet:///modules/pg_bigfix/prod-masthead',  # variable define for Google path 
      'amazon' => 'puppet:///modules/pg_bigfix/prod-masthead', # variable define for Amazon path
      'azure' => 'puppet:///modules/pg_bigfix/prod-masthead', # Variable define for Azure path 
    }

    $_file_mode_masthead = $facts['kernel'] ? { # file mode masthead variable define for checking kernel
      'Linux' => '0600', # variable linux define for permission
      default => undef, # variable default define for default permission 
    }

    case $facts['kernel'] { # Test case define for Kernel
      'Linux': { # condition started for Linux
        $_install_options      = undef # variable install options for default permissions
        $_local_masthead_path  = '/etc/opt/BESClient/actionsite.afxm' # variable local_masthead_path  define for file  path 
        $_local_installer_path = "/tmp/${pg_bigfix::installer_name}" # variable local_installer_path define for installer name
        $_local_gpg_key_path   = '/var/tmp/RPM-GPG-KEY-BigFix-9-V2' # variable local_gpg_key_path define for gpg key path 

        file { '/etc/opt/BESClient/': # file module being called
          ensure => directory, # parameter to make directory
          mode   => '0440', # parameter to set the permissions 
          before => File['BigFix Masthead'], # parameter to make directory before Bigfix Masthead
        }

        if ($facts['os']['name'] == 'RedHat') or ($facts['os']['name'] == 'OracleLinux') { # condition to check os vendor 
          # Add BigFix GPG Key
          file { $_local_gpg_key_path: # file module being called 
            ensure => file, # parameter ensure creating file 
            source => 'puppet:///modules/pg_bigfix/RPM-GPG-KEY-BigFix-9-V2', # parameter source used for keeping gpg key path
            mode   => '0440', # parameter mode used for permissions
          }
          ~> exec { 'Add BigFix GPG Key': # module execute being used for gpg key
            command  => "rpm --import ${_local_gpg_key_path}", }", #parameter command is being used to install the gpg key
            provider => shell, # parameter provider being used for shell
            unless   => 'rpm -q gpg-pubkey --qf \'%{SUMMARY}\n\' | grep -q BigFix', # parameter unless used for checking GPG key
            before   => Package[$pg_bigfix::package_name], # parameter before is define for  executing in sequence
          }
        }
      }
      'windows': { # module windows define
        $_install_options      = ['/S','/v"/qn"'] # variable install_options define for installation parameters
        $_local_masthead_path  = 'C:\\Windows\\Temp\\masthead.afxm' # variable local_masthead_path define for masthead file 
        $_local_installer_path = "C:\\Windows\\Temp\\${pg_bigfix::installer_name}" # variable local_installer_path for installer path 
      }
      default: { fail("Kernel ${facts['kernel']} is not supported.") } # Variable define to check is it supportable or not 
    }

    pg_file_from_storage { $_local_installer_path: # module pg_file _from_storage is defined
      key    => "${pg_bigfix::cloud_installer_path}/${pg_bigfix::installer_name}", # module pg_file _from_storage is defined
      before => Package[$pg_bigfix::package_name], # variable before set for sequence to execute
    }

    file { 'BigFix Masthead': # File module defined 
      ensure  => file, # parameter ensure is being used to create file
      path    => $_local_masthead_path, # parameter path is being used to hold the path
      source  => $_puppet_masthead_path, # parameter source is being used to hold source path
      replace => false, #parameter replace is being used to deny replace the file 
      mode    => $_file_mode_masthead, # parameter mode define for file mode
      seltype => 'etc_runtime_t', # parameter seltype define for file type
    }
    -> package { $pg_bigfix::package_name: # package module has been defined
      ensure          => installed,  # parameter ensure defined for ensuring the installation
      provider        => $_package_provider, # parameter provider is define for package parameter
      source          => $_local_installer_path, # parameter	 source is define to holding source path
      install_options => $_install_options, # Parameter install_options define for installation types
    }
  } # Version is empty = BigFix client is not installed # condition is to check the installation status
}