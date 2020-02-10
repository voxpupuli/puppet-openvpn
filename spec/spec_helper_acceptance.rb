require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  # Configure all nodes in nodeset
  c.before :suite do
    install_module
    install_module_dependencies

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
end
