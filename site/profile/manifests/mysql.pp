# Database on db0 - four different DBs, monitored by Nagios

class profile::mysql {
  class { '::mysql::server':
    root_password => 'supersecretpassword',
    remove_default_accounts => true,
    override_options => {
      'mysqld' => {
        'bind-address' => '0.0.0.0'
      }
    }
  }

  $mysql_dbs = [ 'db1', 'db2', 'db3', 'db4' ]

  package { "nagios-plugins-mysql":
    ensure => present,
  }

  # This is bogus. We should be generating this dynamically, based upon
  # the databases that are being created and hence need to be monitored.
  # Unfortunately, we can't use the nagios_command defined type for that
  # purpose, as the Nagios server has a different syntax for this stuff
  # to the NRPE daemon. So for the sake of getting this done expediently,
  # I'm hard coding. (Probably need to use concat::fragment to do the
  # job, but this has dragged on long enough without figuring that out as
  # well.)
  file { "/etc/nrpe.d/mysql.cfg":
    ensure => present,
    owner  => 'nrpe',
    mode   => '0600',
    source => 'puppet:///modules/profile/mysql-nrpe.cfg',
  }

  $mysql_dbs.each |Integer $index, String $value| {
    mysql::db { $value:
      user     => "${value}_user",
      password => "${value}_pass",
      dbname   => $value,
      host     => 'localhost',
      grant    => ['SELECT','UPDATE'],
    }

    @@nagios_service { "${value}.$::fqdn-mysql":
      ensure => present,
      #action_url => "http://${::fqdn}:${port}",
      # This demonstrates the basic idea, but it's insecure. Real world, I would
      # use a CA signed certificate for authentication.
      check_command => "check_nrpe!-H ${::hostname} -c check_${value}",
      host_name => "$::hostname",
      use => 'generic-service',
      service_description => "MySQL - ${value} @ ${hostname}",
    }
  }
}
