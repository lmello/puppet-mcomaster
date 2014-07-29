class mcomaster::package {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }
  $manage_repo     = $mcomaster::manage_repo
  $yumrepo_name    = $mcomaster::yumrepo_name
  $package_version = $mcomaster::package_version
  if $manage_repo == true { 
    yumrepo { $yumrepo_name:
      descr    => 'mcomaster',
      baseurl  => 'http://yum.mcomaster.org/snapshots/el6/$basearch',
      enabled  => 1,
      gpgcheck => 0,
    }
  }
  exec { 'clear_mcomaster_yum':
    command => "/usr/bin/yum --disablerepo=\'*\' --enablerepo=${yumrepo_name} clean all",
    require => Yumrepo[$yumrepo_name]
  }
  package { 'mcomaster':
    ensure  => $package_version,
    require => [ Yumrepo[$yumrepo_name], Exec['clear_mcomaster_yum'] ],
  }
}
