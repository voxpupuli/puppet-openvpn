require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker do |host|
  manifest = <<-PUPPET
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

  PUPPET
  apply_manifest_on(host, manifest, catch_failures: true)
end
