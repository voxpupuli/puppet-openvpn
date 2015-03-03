# -*- mode: ruby -*-
# vi: set ft=ruby :

def server_config(config)
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = 'vagrant'
    puppet.manifest_file  = 'server.pp'
    puppet.temp_dir = '/tmp'
    puppet.options = ['--modulepath=/tmp/modules']
  end
end

def client_config(config)
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = 'vagrant'
    puppet.manifest_file  = 'client.pp'
    puppet.temp_dir = '/tmp'
    puppet.options = ['--modulepath=/tmp/modules']
  end
end

Vagrant::Config.run(2) do |config|

  config.vm.provision :shell, path: 'vagrant/provision_module.sh'

  config.vm.define :server_ubuntu do |c|
    c.vm.hostname = 'server'
    c.vm.box = 'ubuntu/trusty64'
    server_config c
    c.vm.network :private_network, ip: '10.255.255.10'
  end

  config.vm.define :client_ubuntu do |c|
    c.vm.hostname = 'client'
    c.vm.box = 'ubuntu/trusty64'
    client_config c
    c.vm.network :private_network, ip: '10.255.255.20'
  end
end
