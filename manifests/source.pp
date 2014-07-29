class mcomaster::source($source_repo='https://github.com/ajf8/mcomaster',
  $source_ref='master',
  $source_path='/usr/share/mcomaster',
  $mcomaster_env='production', 
  $system_user='mcomaster',
  $system_group='mcomaster') {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }
  vcsrepo { $source_path:
    ensure   => latest,
    provider => git,
    source   => $source_repo,
    revision => $source_ref,
  }
  include mcomaster::ruby193
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
