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
    c.vm.network :hostonly, '10.255.255.10'
  end

  config.vm.define :server_centos do |c|
    c.vm.box = 'centos63'

    c.vm.provision :shell, :inline => 'if [ ! -f rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm ]; then wget -q http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm; fi'
    c.vm.provision :shell, :inline => 'yum install -y rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm || exit 0'

    server_config c
    c.vm.network :hostonly, '10.255.255.11'
  end

  config.vm.define :client_ubuntu do |c|
    c.vm.box = 'precise64'
    client_config c
    c.vm.network :hostonly, '10.255.255.20'
  end

end
