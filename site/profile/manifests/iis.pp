# iis with ASP.Net on web2 and web3.
# Remove default website, four different websites on different ports
# monitor in Nagios
# load balanced on lb0
class profile::iis {
  iis_feature { [ 'Web-WebServer', 'Web-Scripting-Tools']:
    ensure => present,
  }

  #iis_site { 'Default Web Site':
  #  ensure  => absent,
  #  require => Iis_feature['Web-WebServer'],
  #}

  $iis_vhosts = [ 'vhost1', 'vhost2', 'vhost3', 'vhost4' ]

  #$apache_vhosts.each |Integer $index, String $value| {
  #  $port = 8000 + $index
  #  apache::vhost { "${value}.$::fqdn":
  #    port    => $port,
  #    docroot => "/var/www/${value}",
  #  }
#
    #@@nagios_service { "${value}.$::fqdn-http":
    @@nagios_service { "blah.$::fqdn-http":
      ensure => present,
      action_url => "http://${::fqdn}/",
      check_command => "check_http!-p 80 -I $::ipaddress",
      host_name => "$::hostname",
      use => 'generic-service',
      service_description => "http - blah ${hostname}",
    }
#  }

}
