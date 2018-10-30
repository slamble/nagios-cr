# Apache server for Nagios monitoring

class profile::apache_nagios {
  class { '::apache':
    default_vhost => false,
    mpm_module    => prefork, # required for PHP
  }

  class { 'apache::mod::php':
  }

  $apache_vhosts = [ 'mon0' ]

  apache::vhost { 'mon0':
    port => 80,
    directories => [
      { 'path'     => '/usr/lib64/nagios/cgi-bin/',
        'provider' => 'directory',
        options    => [ 'ExecCGI' ],
        auth_name  => 'Nagios Access',
        auth_type  => 'Basic',
        auth_user_file => '/etc/nagios/passwd',
        require    => {
          enforce => 'all',
          requires => [
            'all granted',
            'valid-user'
          ]
        }
      },
      { 'path'     => '/usr/share/nagios/html',
        'provider' => 'directory',
        auth_name  => 'Nagios Access',
        auth_type  => 'Basic',
        auth_user_file => '/etc/nagios/passwd',
        require    => {
          enforce => 'all',
          requires => [
            'all granted',
            'valid-user'
          ]
        }
      }
    ],
    aliases => [
      { scriptalias => '/nagios/cgi-bin',
        path        => '/usr/lib64/nagios/cgi-bin',
      },
      { alias => '/nagios',
        path  => '/usr/share/nagios/html',
      }
    ],
    docroot => "/var/www/${value}",
  }
}
