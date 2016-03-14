#
# OVH Breizhcamp
#
# @author: Arnaud Morin <arnaud.morin@corp.ovh.com>
#

#
# Puppet Master node definition
#
node /^puppet/ {
  # Hello world!
  notify { 'Bonjour tout le monde du breizhcamp !!!': }

  # Install puppetdb
  class {'::puppetdb':
    listen_address => $::ipaddress,
  }
  class { 'puppetdb::master::config': }

  # Make sure puppet agent run every minute
  cron { 'puppet-agent':
    ensure      => present,
    user        => root,
    minute      => '*',
    command     => '/opt/puppetlabs/bin/puppet agent -t -v',
  }

  # TODO: install and configure haproxy
}



#
# Web Server node definition
#
node /^web/ {
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

  # TODO: declare haproxy backend
}
