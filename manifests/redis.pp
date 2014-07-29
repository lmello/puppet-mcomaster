class mcomaster::redis {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }
  class { '::redis':
    version => $mcomaster::redis_version,
    redis_max_memory => $mcomaster::redis_max_memory,
    redis_port => $mcomaster::redis_port
  }
}
