if $facts['os']['family'] == 'RedHat' {
  package { 'epel-release':
    ensure => present,
  }
}

$netcat_package_name = $facts['os']['family'] ? {
  'Debian' => 'netcat-openbsd',
  'RedHat' => 'nc',
  'Archlinux' => 'gnu-netcat',
  default  => 'netcat',
}

node /vpnserver/ {
  package { $netcat_package_name:
    ensure => present,
  }
}

node /vpnclient/ {
  package { ['tar','openvpn']:
    ensure => present,
  }
}

node default {
  package { $netcat_package_name:
    ensure => present,
  }
}
