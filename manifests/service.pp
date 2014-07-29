class mcomaster::service {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }
  $require_install_method = $mcomaster::require_install_method
  service {'mcomaster':
    enable  => true,
    ensure  => running,
    require => [ $require_install_method, Class['::mcomaster::ruby193'],
                 Class['::mcomaster::config::mcomaster'], 
                 Exec['create_mcomaster_db'] ]
  }
}
