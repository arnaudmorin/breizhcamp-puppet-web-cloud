#
# OVH Breizhcamp
#
# author: Arnaud Morin <arnaud.morin@corp.ovh.com>
#

#
# Puppet Master node definition
#
node /^puppet/ {
  # Hello world!
  notify { 'Bonjour tout le monde du breizhcamp !!!': }

  # Install puppetdb
  class {'::puppetdb':
    listen_address => '0.0.0.0',
  }
  class { 'puppetdb::master::config': }

  # Make sure puppet agent run every minute
  cron { 'puppet-agent':
    ensure      => present,
    user        => root,
    minute      => '*',
    command     => '/opt/puppetlabs/bin/puppet agent -t -v',
  }

  # install and configure haproxy
  class { 'haproxy': }

  haproxy::listen { 'stats':
    ipaddress        => $::ipaddress,
    ports            => '9090',
    options          => {
      'mode'  => 'http',
      'stats' => [
        'uri /'
      ],
    },
  }

  haproxy::listen { 'web':
    ipaddress        => $::ipaddress,
    ports            => '80',
    options          => {
      'option'  => ['tcplog'],
      'balance' => 'roundrobin',
    },
  }
}



#
# Web Server node definition
#
node /^web/ {
  # Make sure puppet agent run every minute
  cron { 'puppet-agent':
    ensure      => present,
    user        => root,
    minute      => '*',
    command     => '/opt/puppetlabs/bin/puppet agent -t -v',
  }

  # Installation du nécessaire pour python
  class { 'python' :
    version    => 'system',
    pip        => 'present',
    dev        => 'absent',
    virtualenv => 'absent',
    gunicorn   => 'absent',
  }

  # Installation de Flask (genre de serveur web pour python)
  python::pip { 'Flask': }

  # Install python web application
  package { 'git':
    ensure    => 'latest',
  }
  ->
  vcsrepo { '/opt/demoflask':
    ensure    => latest,
    provider  => git,
    source    => 'https://github.com/arnaudmorin/puppet-demoflask.git',
  }
  ->
  exec { '/opt/demoflask/start.py &':
    unless    => '/bin/pidof -x start.py',
    require   => Python::Pip['Flask'],
  } 

  # TODO: declare haproxy backend
}
