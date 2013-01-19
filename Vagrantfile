# -*- mode: ruby -*-
# vi: set ft=ruby :

def server_config(config)
  config.vm.provision :puppet, :module_path => '..' do |puppet|
    puppet.manifests_path = "vagrant"
    puppet.manifest_file  = "server.pp"
  end
end

def client_config(config)
  config.vm.provision :puppet, :module_path => '..' do |puppet|
    puppet.manifests_path = "vagrant"
    puppet.manifest_file  = "client.pp"
  end
end

Vagrant::Config.run do |config|

  config.vm.define :server_ubuntu do |c|
    c.vm.box = 'precise64'
    server_config c
  end

  config.vm.define :server_centos do |c|
    c.vm.box = 'centos63'
    server_config c
  end

  config.vm.define :client_ubuntu do |c|
    c.vm.box = 'precise64'
    client_config c
  end

end
