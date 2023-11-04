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
