class mcomaster::source {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }
  $source_repo   = $mcomaster::source_repo
  $source_ref    = $mcomaster::source_ref
  $source_path   = $mcomaster::source_path
  $mcomaster_env = $mcomaster::mcomaster_env
  $system_user   = $mcomaster::system_user
  $system_group  = $mcomaster::system_group
  vcsrepo { $source_path:
    ensure   => latest,
    provider => git,
    source   => $source_repo,
    revision => $source_ref,
  }
}
