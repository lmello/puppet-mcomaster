# == Class: mcomaster
#
# This is the main class of mcomaster, it abstract the access to other
# mcomaster module class. 
#
# === Parameters
#
# [*mcomaster_app*]
#   Should we configure the mcomaster application, default: true,
#
# [*mcollective_client*]
#   Should we configure the pre-req of mcollective client, default: true,
#
# [*mcollective_server*]
#   Should we configure the pre-req of mcollective servers, default: true,
#
# [*redis_manage*] 
#   Should we install and configure redis, default: true
#
# [*redis_host*]
#   Specify the redis hostname or ipaddress, default: 127.0.0.1
#
# [*redis_port*]
#   Specify the redis port, default: 6379
#
# [*mcomaster_port*] 
#   Specify the port mcomaster should listen at, default: 3000
#
# [*admin_user*]
#   mcomaster admin username, default: mcomaster
#
# [*admin_pass*]
#   mcomaster admin password, default: mcomaster123 
#
# [*admin_email*]
#   mcomaster admin email, default: mcomaster@example.com
#
# [*mcomaster_env*] 
#   mcomaster rails environment, default: production
#
# [*mcomaster_use_thin*] 
#   mcomaster enable and use thin (0=false, 1=true), default: 0
#
# [*mcomaster_thin_use_ssl*]
#   mcomaster enable thin ssl (0=false, 1=true), default: 0
#
# [*mcomaster_path*]
#   path where mcomaster application is, default: '/usr/share/mcomaster'
#
# [*mcomaster_dbtype*]
#   type of database, default: 'embedded'
#   currently supported types: 'embedded'
# 
# [*mcomaster_db_host*]
#   database hostname, default: nil 
#
# [*mcomaster_db_user*]
#   database username, default: nil
#
# [*mcomaster_db_port*]
#   database port, default: nil
#
# [*mcomaster_db_name*]
#   database name, default: mcomaster
#
# [*manage_system_user_and_group*]
#   should manage system user and group for mcomaster  (true or false), default: true
#
# [*manage_repo*]
#   should manage yum repository for mcomaster and/or ruby (true or false), default: true
#
# [*system_user*] 
#   mcomaster system user name (string), default: 'mcomaster'
#
# [*system_group*
#   mcomaster system group name (string), default: 'mcomaster'
#
# [*install_method*]
#   installation method, currently supports package, source and vagrant. default: package
#   if using vagrant, it should share the mcomaster gitrepository on virtual machine $mcomaster_path. 
# 
# [*source_repo*] 
#   Git repository that will be used for source install. 
#   default: https://github.com/ajf8/mcomaster
#
# [*source_ref*] 
#   Git ref of the repository used for source install. 
#   default: "master"
# === Variables
#
# This module does not require external enc, variables. 
#
# === Examples
#
#  class { mcomaster:
#  }
#
# === Authors
#
# Leonardo Rodrigues de Mello <l@lmello.eu.org>
#
# === Copyright
#
# Copyright 2014 Leonardo Rodrigues de Mello.
#
class mcomaster (
  #module should configure
  $mcomaster_app                = true,
  $mcollective_client           = true,
  $mcollective_server           = true,
  $redis_manage                 = true,
  #redis configuration
  $redis_host                   = '127.0.0.1',
  $redis_port                   = 6379,
  $redis_version                = '2.8.13',
  $redis_memory                 = '300mb',
  #mcomaster admin user
  $admin_user                   = 'mcomaster',
  $admin_pass                   = 'mcomaster123',
  $admin_email                  = 'mcomaster@example.com',
  #mcomaster application
  $mcomaster_env                = 'production',
  $mcomaster_path               = '/usr/share/mcomaster',
  $mcomaster_port               = 3000,
  $mcomaster_use_thin           = 0,
  $mcomaster_thin_use_ssl       = 0,
  #mcomaster database
  $mcomaster_dbtype             = 'embedded',
  $mcomaster_db_host            = nil,
  $mcomaster_db_user            = nil,
  $mcomaster_db_port            = nil,
  $mcomaster_db_name            = 'mcomaster',
  #mcomaster user and group
  $manage_system_user_and_group = true,
  $system_user                  = 'mcomaster',
  $system_group                 = 'mcomaster',
  #mcomaster repositories
  $manage_repo                  = true,
  $yum_reponame                 = 'mcomaster',
  #Install methods
  $install_method               = 'package',
  #mcomaster package version
  $package_version              = 'latest',
  #ruby193
  $ruby_package_basename        = 'ruby193',
  #source install method
  $source_repo                  = 'https://github.com/ajf8/mcomaster',
  $source_ref                   = 'master'
   ) {
  #configure mcollective_client mcomaster pre-req
  if $mcollective_client == true {
     class {'::mcomaster::config::mcollective::client':}
  }
  #configure mcollective_server mcomaster pre-req
  if $mcollective_server == true {
    class {'::mcomaster::config::mcollective::server':}
  }
  if $redis_manage == true {
    class {'::mcomaster::redis': }
  }
  #install and configure mcomaster application.
  if ($mcomaster_app  == true) {
    case $install_method {
       'package':  {
                     $require_install_method = Class['mcomaster::package']
                     class { '::mcomaster::ruby193':}->
                     class { '::mcomaster::package':} ->
                     class { '::mcomaster::config::mcomaster':}->
                     class { '::mcomaster::service':}
                   }
       'source':   {
                     $require_install_method = Class['mcomaster::source']
                     class { '::mcomaster::ruby193':}->
                     class { '::mcomaster::source':}->
                     class { '::mcomaster::config::mcomaster':}->
                     class { '::mcomaster::service':}
                   }
       'vagrant':  {
                     $require_install_method = Class['mcomaster::vagrant']
                     class { '::mcomaster::ruby193':}->
                     class { '::mcomaster::source':}->
                     class { '::mcomaster::config::mcomaster':}->
                     class { '::mcomaster::service':}
                   }
       default:   {fail("unsuported ${install_method} for mcomaster") }
    }

    exec { 'create_mcomaster_db':
      command     => '/usr/bin/scl enable ruby193 "bin/rake db:reset"',
      environment => 'RAILS_ENV=production',
      cwd         => $mcomaster_path,
      user        => $system_user,
      group       => $system_group,
      creates     => "${mcomaster_path}/db/production.sqlite3",
      require     => [$require_install_method, User[$system_user], Group[$system_group]]
    }

    if ($admin_user and $admin_pass and $admin_email) {
      mcomaster::adduser { $admin_user:
        email    => $admin_email,
        password => $admin_pass,
      }
    }

  } #end mcomaster_app == true

}
