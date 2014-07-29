class mcomaster::config::mcomaster { 
  $manage_system_user_and_group = $mcomaster::manage_system_user_and_group
  $system_group                 = $mcomaster::system_group
  $system_user                  = $mcomaster::system_user
  $require_install_method       = $mcomaster::require_install_method
  $mcomaster_path               = $mcomaster::mcomaster_path
  

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
  $mcomaster_files = ["${os_config_path}/mcomaster", '/etc/mcomaster/application.yml' ]
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
}
