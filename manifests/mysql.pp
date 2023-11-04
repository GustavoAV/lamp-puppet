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
