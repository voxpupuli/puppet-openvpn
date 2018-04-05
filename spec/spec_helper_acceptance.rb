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
      case host[:platform]
      when /debian-7-amd64|debian-8-amd64|ubuntu-16.04-amd64/
        on host, puppet('module', 'install', 'puppetlabs-apt')
        pp = <<-EOS
        package { 'netcat-openbsd' :
          ensure => present,
        }
        EOS
      when /el-6-x86_64|el-7-x86_64/
        on host, puppet('module', 'install', 'stahnma-epel')
        pp = <<-EOS
        include ::epel
        package { 'nc' :
          ensure => present,
        }
        EOS
      end

      apply_manifest_on(host, pp, catch_failures: true)
    end
  end
end
