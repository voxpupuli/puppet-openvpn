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
    hosts.each do |host|
      if fact('os.family') == 'RedHat'
        install_module_from_forge('stahnma-epel', '>= 1.3.0 < 2.0.0')
        apply_manifest_on(host, 'include ::epel', catch_failures: true)
      end
    end
  end
end
