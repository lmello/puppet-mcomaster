class mcomaster::ruby193 {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }
  $manage_repo=$mcomaster::manage_repo
  $ruby_basename=$mcomaster::ruby_package_basename
  if $create_yumrepo {
    yumrepo { 'ruby_scl':
      descr    => 'Ruby SCL',
      baseurl  => 'http://people.redhat.com/bkabrda/ruby193-rhel-6/',
      enabled  => 1,
      gpgcheck => 0,
    }
  }
  $ruby_packages = ["$ruby_basename-runtime",
    "$ruby_basename-rubygem-io-console",
    "$ruby_basename-rubygem-rdoc",
    "$ruby_basename-rubygem-diff-lcs",
    "$ruby_basename-libyaml",
    "$ruby_basename-rubygem-bigdecimal",
    "$ruby_basename-rubygem-json",
    "$ruby_basename-ruby",
    "$ruby_basename-rubygems",
    "$ruby_basename-rubygem-rake",
    "$ruby_basename-rubygem-thor",
    "$ruby_basename-ruby-libs",
    "$ruby_basename-ruby-irb",
    "$ruby_basename-rubygem-net-http-persistent",
    "$ruby_basename-rubygem-bundler"]
  package {$ruby_packages:
    ensure => latest
  }
}
