node default {}

$mysql_db_host = 'localhost'
$mysql_db_user = 'user'
$mysql_db_pass = 'pass'
$mysql_db_name = 'app'
$mysql_root_password = 'supersecret'
$apache_website_name = 'example'

# Configures a basic LAMP stack
class lamp {
  # Install basic packages
  package { [
      'apt-transport-https',
      'ca-certificates',
      'curl',
      'git',
      'gpg',
      'htop',
      'jq',
      'openssh-client',
      'vim',
      'wget',
    ]:
      ensure => 'installed',
  }

  include lamp::mysql
  # include lamp::apache
}

# Configures MySQL
class lamp::mysql {
  # Install MySQL server
  class { 'mysql::server':
    root_password           => $::mysql_root_password,
    remove_default_accounts => true,
  }

  # Create database
  mysql::db { $::mysql_db_name:
    user     => $::mysql_db_user,
    password => $::mysql_db_pass,
    host     => $::mysql_db_host,
    grant    => ['ALL'],
  }

  # Start and enable MySQL
  service { 'mysql':
    ensure    => running,
    enable    => true,
    subscribe => Package['mysql-server'],
  }
}

# Configures the LAMP stack in a specific node
node '192.168.56.20' {
  include lamp
}
