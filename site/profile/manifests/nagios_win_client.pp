class profile::nagios_win_client {
#  include profile::nagios_base

  # This is more than a little bit ugly. In the real world, I'd repackage
  # ncpa as a chocolatey package, and use the chocolatey provider to
  # install. Meanwhile, though...
  #
  # NB: Parameterise the Nagios token!
  file { 'C:\\Windows\\Temp\\ncpa-2.1.6.exe':
    ensure => present,
    source => 'https://assets.nagios.com/downloads/ncpa/ncpa-2.1.6.exe',
  } ->
  package { 'NCPA':
    ensure  => '2.1.6',
    source  => 'C:\\Windows\\Temp\\ncpa-2.1.6.exe',
    install_options => [ '/S', { '/TOKEN' => 'SomeNagiosToken' } ],
  } ->
  file { 'C:\\Program Files (x86)\\Nagios\\NCPA\\etc\\ncpa.cfg':
    ensure => present,
    source => 'puppet:///modules/profile/ncpa.cfg',
  }
  service { 'ncpalistener':
    ensure => running,
    subscribe => File['C:\\Program Files (x86)\\Nagios\\NCPA\\etc\\ncpa.cfg'],
  }
  service { 'ncpapassive':
    ensure => running,
    subscribe => File['C:\\Program Files (x86)\\Nagios\\NCPA\\etc\\ncpa.cfg'],
  }

  @@nagios_host { $::hostname:
    ensure             => present,
    address            => $::ipaddress,
    check_command      => 'check_ncpa!-t \'SomeNagiosToken\' -P 5693 -M system/agent_version',
    max_check_attempts => 5,
    hostgroups         => 'win-servers',
  }
}
