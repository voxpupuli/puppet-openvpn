require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker do |host|
  # Configure all nodes in nodeset
  install_server_packages = %(
    if $facts['os']['name'] == 'CentOS' {
      package { 'epel-release':
        ensure => present,
      }
    }

    $package_name = $facts['os']['family'] ? {
      'Debian' => 'netcat-openbsd',
      'RedHat' => 'nc',
      default  => 'netcat',
    }
    package { $package_name:
      ensure => present,
    }
  )
  apply_manifest_on(hosts_as('vpnserver'), install_server_packages, catch_failures: true)

  install_client_packages = %(
    if $facts['os']['name'] == 'CentOS' {
      package { 'epel-release':
        ensure => present,
      }
    }

    package { ['tar','openvpn'] :
      ensure => present,
    }
  )
  apply_manifest_on(hosts_as('vpnclienta'), install_client_packages, catch_failures: true)
end
