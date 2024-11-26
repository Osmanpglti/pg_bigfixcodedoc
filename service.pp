class pg_bigfix::service {   # pg_bigfix class defined with service module
  service { $pg_bigfix::service_name: # parameter service used for service name
    ensure => running, # parameter service used for service name
    enable => true, # parameter true is being used for make service permanently running
  }
}