# Apache server with PHP, remove default website, four different
# websites on different ports
# All websites to be monitored automatically
# XXX: All websites to be load balanced on lb0

class profile::apache {
  class { '::apache':
    default_vhost => false,
    mpm_module    => prefork, # required for PHP
  }

  class { 'apache::mod::php':
  }

  $apache_vhosts = [ 'vhost1', 'vhost2', 'vhost3', 'vhost4' ]

  $apache_vhosts.each |Integer $index, String $value| {
    $port = 8000 + $index
    apache::vhost { "${value}.$::fqdn":
      port    => $port,
      docroot => "/var/www/${value}",
    }

    @@nagios_service { "${value}.$::fqdn-http":
      ensure => present,
      action_url => "http://${::fqdn}:${port}",
      check_command => "check_http!-p ${port} -I $::ipaddress",
      host_name => "$::hostname",
      use => 'generic-service',
      service_description => "http - ${value} ${hostname}",
    }
  }
}
