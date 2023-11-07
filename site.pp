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
  include lamp::apache
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

# Install and configure Apache and PHP
class lamp::apache {
  # Install apache and php
  package { [
      'apache2',
      'libapache2-mod-php',
      'php',
      'php-mysql',
    ]:
      ensure  => installed,
  }

  # Set index.php as default homepage
  file_line { 'Set index.php as default homepage':
    ensure  => present,
    path    => '/etc/apache2/mods-enabled/dir.conf',
    line    => '        DirectoryIndex index.php index.html',
    match   => '^(\s+DirectoryIndex)',
    replace => true,
    require => Package['apache2'],
    notify  => Service['apache2'],
  }

  # Create custom website dir
  file { "/var/www/${::apache_website_name}":
    ensure  => directory,
    mode    => '0755',
    require => Package['apache2'],
  }

  # Generate basic html index
  file { "/var/www/${::apache_website_name}/index.html":
    ensure  => file,
    content => join([
        '<html>',
        '  <head>',
        "    <title>Welcome to ${::apache_website_name}!</title>",
        '  </head>',
        '  <body>',
        "    <h1>Success! The ${::apache_website_name} server block is working!</h1>",
        '  </body>',
        '</html>',
    ]),
    mode    => '0644',
    require => File["/var/www/${::apache_website_name}"],
    notify  => Service['apache2'],
  }

  # Generate basic php index
  file { "/var/www/${::apache_website_name}/index.php":
    ensure  => file,
    content => join([
        "<!DOCTYPE html>\n",
        "<html>\n",
        "\n",
        "<head>\n",
        "    <title>Connecting PHP with MySQL</title>\n",
        "</head>\n",
        "\n",
        "<body>\n",
        "\n",
        "    <?php\n",
        "    // Database credentials\n",
        "    \$servername = '${::mysql_db_host}';\n",
        "    \$username = '${::mysql_db_user}';\n",
        "    \$password = '${::mysql_db_pass}';\n",
        "    \$database = '${::mysql_db_name}';\n",
        "\n",
        "    // Create connection\n",
        "    \$conn = new mysqli(\$servername, \$username, \$password, \$database);\n",
        "\n",
        "    // Verify connection\n",
        "    if (\$conn->connect_error) {\n",
        "        die('Connection failed: ' . \$conn->connect_error);\n",
        "    }\n",
        "\n",
        "    echo 'Connection with MySQL successful!';\n",
        "\n",
        "    // Close connection\n",
        "    \$conn->close();\n",
        "    ?>\n",
        "\n",
        "</body>\n",
        "\n",
        "</html>\n",
    ]),
    mode    => '0644',
    require => File["/var/www/${::apache_website_name}"],
    notify  => Service['apache2'],
  }

  # Generate VirtualHost config
  file { "/etc/apache2/sites-available/${::apache_website_name}.conf":
    ensure  => file,
    content => join([
        "<VirtualHost *:80>\n",
        "    ServerAdmin webmaster@localhost\n",
        "    ServerName ${::apache_website_name}\n",
        "    ServerAlias www.${::apache_website_name}\n",
        "    DocumentRoot /var/www/${::apache_website_name}\n",
        "    ErrorLog \${APACHE_LOG_DIR}/error.log\n",
        "    CustomLog \${APACHE_LOG_DIR}/access.log combined\n",
        "</VirtualHost>\n",
    ]),
    mode    => '0644',
    require => Package['apache2'],
    notify  => Service['apache2'],
  }

  # Enable website
  exec { 'a2ensite':
    command => "/usr/sbin/a2ensite ${::apache_website_name}.conf",
    unless  => "/usr/bin/test -L /etc/apache2/sites-enabled/${::apache_website_name}.conf",
    require => File["/etc/apache2/sites-available/${::apache_website_name}.conf"],
    notify  => Service['apache2'],
  }

  # Disable default website
  exec { 'a2dissite':
    command => '/usr/sbin/a2dissite 000-default.conf',
    onlyif  => '/usr/bin/test -L /etc/apache2/sites-enabled/000-default.conf',
    notify  => Service['apache2'],
  }

  # Validate configs
  exec { 'apache-configtest':
    command => '/usr/sbin/apache2ctl configtest',
    notify  => Service['apache2'],
    require => File["/etc/apache2/sites-available/${::apache_website_name}.conf"],
  }

  # Start and enable apache service
  service { 'apache2':
    ensure  => running,
    enable  => true,
    require => [
      Exec['a2ensite'],
      Exec['a2dissite'],
      Exec['apache-configtest'],
    ],
  }
}

# Configures the LAMP stack in a specific node
node '192.168.56.20' {
  include lamp
}
