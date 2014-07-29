# == Class: mcomaster
#
# This is the main class of mcomaster, it abstract the access to other
# mcomaster module class. 
#
# === Parameters
#
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
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class mcomaster ($redis_host='127.0.0.1', 
  $redis_port=6379,
  $mcomaster_port=3000,
  $admin_user='mcomaster',
  $admin_pass='mcomaster123',
  $admin_email='mcomaster@example.com',
  $mcomaster_env='production',
  $mcomaster_use_thin=0,
  $mcomaster_thin_use_ssl=0,
  $mcomaster_path='/usr/share/mcomaster',
  $mcomaster_dbtype='embedded', 
  $mcomaster_db_host=nil, 
  $mcomaster_db_user=nil,
  $mcomaster_db_port=nil,
  $mcomaster_db_name=mcomaster,
  $manage_system_user_and_group=true,
  $manage_repo=true,
  $yum_reponame='mcomaster',
  $system_user='mcomaster',
  $system_group='mcomaster',
  $package_version='latest',
  $install_method='package',
  $source_repo='https://github.com/ajf8/mcomaster',
  $source_ref='master' ) {
  
  $mcomaster_files = ["${os_config_path}/mcomaster", '/etc/mcomaster/application.yml' ]
  case $::osfamily  { 
    'RedHat': {  $os_config_path = '/etc/sysconfig' } 
    default:  {  fail("Unsuported osfamily ${::osfamily} for mcomaster")}
  }
  case $operatingsystemmajrelease {
    /(6)/: {
           file {'/etc/init.d/mcomaster': 
             source => 'puppet:///modules/mcomaster/mcomaster.init',
             mode   => '0755'
            }
         }
     default: { 
                fail("Unsupported redhat release ${operatingsystemmajrelease} for mcomaster") 
              }
  }

  case $install_method {
     'package':  { class {'mcomaster::package': 
                     create_yumrepo  => $manage_repo, 
                     package_version => $package_version,
                     yumrepo_name   => $yumrepo_name
                   } 
                   $require_install_method = Class['mcomaster::package']
                 }
     'source':   { class {'mcomaster::source': 
                     mcomaster_path => $mcomaster_path,
                     mcomaster_env  => $mcomaster_env, 
                     system_user    => $system_user,
                     system_group   => $system_group,
                     source_ref     => $source_ref, 
                     source_repo    => $source_repo,
                     source_path    => $mcomaster_path
                   } 
                   $require_install_method = Class['mcomaster::source']
                 }
     'vagrant':  { class {'mcomaster::vagrant': 
                     mcomaster_path => $mcomaster_path 
                   } 
                   $require_install_method = Class['mcomaster::vagrant']
                 }
     default:   {fail("unsuported ${install_method} for mcomaster") }
  } 
  if $manage_system_user_and_group == true {
    group {$system_group:}
    user  {$system_user:
      group => $system_group, 
      require => Group[$system_group]
    }
  } 

  file { "${os_config_path}/mcomaster":
    owner    => 'root',
    group    => 'mcomaster',
    mode     => '0640',
    content  => template('mcomaster/sysconfig.erb'),
    require  => $require_install_method,
  }

  file {'/etc/mcomaster': 
    ensure => directory
  }
  file { '/etc/mcomaster/application.yml':
    content => template('mcomaster/application.yml.erb'),
    mode    => '0640',
    owner   => 'root',
    group   => 'mcomaster',
    require => [$require_install_method, Group[$system_group]]
  }

  file {"${mcomaster_path}/config/application.yaml": 
    target  => '/etc/mcomaster/application.yaml',
    ensure  => link,
    require => $require_install_method
  } 

  file {"/etc/mcomaster/database.yaml": 
    content => template('mcomaster/database.yaml.erb'),
    require => $require_install_method,
    mode    => "0640",
    owner   => "root",
    group   => "mcomaster", 
    require => [$require_install_method, Group[$system_group]]
  }
  file {"${mcomaster_path}/config/database.yaml": 
    target  => '/etc/mcomaster/database.yaml',
    ensure  => link,
    require => $require_install_method
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
  service {'mcomaster':
    enable  => true,
    ensure  => running,
    require => [ $require_install_method, File[$mcomaster_files], Exec['create_mcomaster_db'] ]
  }

}
