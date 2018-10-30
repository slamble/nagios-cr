class profile::nagios_client {
  include profile::nagios_base
  package { 'nrpe':
    ensure  => present,
    require => Package['epel-release']
  }
  file { '/etc/nagios/nrpe.cfg':
    owner   => 'root',
    group   => 'nrpe',
    mode    => '0640',
    # source =>
    require => Package['nrpe'],
  }
  file { '/etc/nagios/nrpe.d':
    owner  => 'root',
    group  => 'nrpe',
    mode   => '0755',
    ensure => directory,
  }
  service { 'nrpe':
    ensure => running,
    enable => true,
    hasstatus => true,
    subscribe => File['/etc/nagios/nrpe.cfg'],
  }
  @@nagios_host { $::hostname:
    ensure             => present,
    address            => $::ipaddress,
    check_command      => 'check-host-alive',
    max_check_attempts => 5,
    hostgroups         => 'linux-servers',
  }
}
