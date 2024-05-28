if $facts['os']['name'] == 'CentOS' {
  package { 'epel-release':
    ensure => present,
  }
}

$netcat_package_name = $facts['os']['family'] ? {
  'Debian' => 'netcat-openbsd',
  'RedHat' => 'nc',
  default  => 'netcat',
}

node /^vpnserver\./ {
  package { $netcat_package_name:
    ensure => present,
  }
}

node /^vpnclienta\./ {
  package { ['tar','openvpn'] :
    ensure => present,
  }
}

# CentOS 6 in docker doesn't get a hostname - install all packages
node /^localhost\./ {
  package { ['tar', 'openvpn', $netcat_package_name]:
    ensure => present,
  }
}

# changing the testing CI to out-of-the-box beaker requires a default node statement, so we just mimic what centos 6 requires
node default {
  package { ['tar', 'openvpn', $netcat_package_name]:
    ensure => present,
  }
}
