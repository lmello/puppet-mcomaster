class mcomaster::build { 
  $mcomaster_env = $mcomaster::mcomaster_env
  $source_path   = $mcomaster::mcomaster_path
  $system_user   = $mcomaster::system_user
  $system_group  = $mcomaster::system_group
  exec { 'bundle_install_mcomaster':
    command     => '/usr/bin/scl enable ruby193 "bundle install --path=vendor/"',
    environment => "RAILS_ENV=${mcomaster_env}",
    cwd         => $source_path,
    user        => $system_user,
    group       => $system_group,
    refreshonly => true,
    require     => [User[$system_user], Group[$system_group], 
                    Class[mcomaster::ruby193], Vcsrepo[$source_path]]
  }
  exec { 'compile_assets_mcomaster':
    command     => '/usr/bin/scl enable ruby193 "./bin/rake assets:precompile"',
    environment => "RAILS_ENV=${mcomaster_env}",
    cwd         => $source_path,
    user        => $system_user,
    group       => $system_group,
    refreshonly => true,
    require     => [User[$system_user], Group[$system_group], 
                    Class[mcomaster::ruby193], Vcsrepo[$source_path],
                    Exec['bundle_install_mcomaster']
                   ]
  }
}
