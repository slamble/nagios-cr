class role::win_webserver {

  #This role would be made of all the profiles that need to be included to make a webserver work
  #All roles should include the base profile
  include profile::base
  include profile::iis
  include profile::nagios_win_client
}
