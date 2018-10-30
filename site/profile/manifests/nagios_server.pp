# Install and configure the nagios server

class profile::nagios_server {
  include profile::nagios_base
  include profile::apache_nagios

  package { [ "nagios", "nagios-plugins", "nagios-plugins-nrpe",
              "nagios-plugins-ping", "nagios-plugins-load",
              "nagios-plugins-http", "nagios-plugins-disk",
              "nagios-plugins-ssh", "nagios-plugins-swap",
              "nagios-plugins-users", "nagios-plugins-procs",
              "nagios-plugins-mysql" ]:
    ensure  => installed,
    require => Package['epel-release'],
  }

  file { '/usr/share/nagios/html/config.inc.php':
    ensure  => present,
    owner   => 'root',
    group   => 'apache',
    mode    => '0640',
    content => epp('profile/config.inc.php.epp', { 'nagios_token' => 'SomeTokenValue' }),
    notify  => Service['httpd'],
  }

  file { '/usr/lib64/nagios/plugins/check_ncpa.py':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/check_ncpa.py',
  }

  nagios_hostgroup { 'win-servers':
    target => '/etc/nagios/conf.d/nagios_hostgroup.cfg',
    owner  => 'nagios',
    ensure => present,
  }
  Nagios_host <<| |>> {
    target => '/etc/nagios/conf.d/nagios_host.cfg',
    owner  => 'nagios',
    notify => Service['nagios'],
  }
  Nagios_service <<| |>> {
    target => '/etc/nagios/conf.d/nagios_service.cfg',
    owner  => 'nagios',
    notify => Service['nagios'],
  }
  # Really should be setting resource defaults, rather than repeating the owner/notify/target
  # parameters every time..
  nagios_command { 'check_ncpa':
    ensure       => present,
    command_line => '$USER1$/check_ncpa.py -H $HOSTADDRESS$ $ARG1$',
    owner        => 'nagios',
    notify       => Service['nagios'],
    target       => '/etc/nagios/conf.d/nagios_command.cfg',
  }
  nagios_command { 'check_mysql':
    ensure       => present,
    command_line => '$USER1$/check_mysql $ARG1$',
    owner        => 'nagios',
    notify       => Service['nagios'],
    target       => '/etc/nagios/conf.d/nagios_command.cfg',
  }
  nagios_command { 'check_nrpe':
    ensure       => present,
    command_line => '$USER1$/check_nrpe $ARG1$',
    owner        => 'nagios',
    notify       => Service['nagios'],
    target       => '/etc/nagios/conf.d/nagios_command.cfg',
  }
  service { 'nagios':
    ensure => running,
    enable => true,
  }
}
