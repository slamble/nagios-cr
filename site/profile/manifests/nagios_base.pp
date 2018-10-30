# Install and configure the nagios server

class profile::nagios_base {
  package { 'epel-release':
    ensure => present,
  }
}
