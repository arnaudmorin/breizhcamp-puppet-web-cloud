node /^puppet/ {
  notify { 'hello': }

  class {'::puppetdb':
    listen_address => $::ipaddress,
  }
  class { 'puppetdb::master::config': }


  class { 'haproxy': }

  haproxy::listen { 'stats':
    ipaddress        => $::ipaddress,
    ports            => '9090',
    options          => {
      'mode'  => 'http',
      'stats' => [
        'uri /',
        'auth puppet:puppet'
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

  cron { 'puppet-agent':
    ensure      => present,
    user        => root,
    minute      => '*',
    command     => '/opt/puppetlabs/bin/puppet agent -t -v',
  }
}


node /^web/ {
  class { 'python' :
    version    => 'system',
    pip        => 'present',
    dev        => 'absent',
    virtualenv => 'absent',
    gunicorn   => 'absent',
  }

  python::pip { 'Flask': }
#  python::pip { 'Flask_redis': }

#  package { 'redis-server':
#    ensure => latest,
#  }

  @@haproxy::balancermember { $::fqdn:
    listening_service => 'web',
    ipaddresses       => $::ipaddress,
    server_names      => $::hostname,
    ports             => '5000',
    options           => 'check',
  }

  cron { 'puppet-agent':
    ensure      => present,
    user        => root,
    minute      => '*',
    command     => '/opt/puppetlabs/bin/puppet agent -t -v',
  }

  package { 'git':
    ensure => 'latest',
  }
  ->
  vcsrepo { '/opt/demoflask':
    ensure => latest,
    provider => git,
    source => 'https://github.com/arnaudmorin/puppet-demoflask.git',
  }
  ->
  exec { '/opt/demoflask/start.py &':
    unless      => '/bin/pidof -x start.py',
    require     => Python::Pip['Flask'],
  }
}

