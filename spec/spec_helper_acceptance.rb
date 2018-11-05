require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'
install_module
install_module_dependencies

RSpec.configure do |c|
  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |_host|
      case fact('os.family')
      when 'RedHat'
        install_module_from_forge_on(hosts_as('agent'), 'stahnma-epel', '>= 1.3.0 < 2.0.0')
        apply_manifest_on(hosts_as('agent'), 'include ::epel', catch_failures: true)

        install_server_packages = %(
          package { ['nc'] :
            ensure => present,
          }
        )
      when 'Debian'
        install_server_packages = %(
          package { ['netcat-openbsd'] :
            ensure => present,
          }
        )
      end

      install_client_packages = %(
        package { ['tar','openvpn'] :
          ensure => present,
        }
      )

      apply_manifest_on(hosts_as('vpnserver'), install_server_packages, catch_failures: true)
      apply_manifest_on(hosts_as('vpnclienta'), install_client_packages, catch_failures: true)
    end
  end
end
