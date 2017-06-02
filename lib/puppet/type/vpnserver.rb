module Puppet
Type.newtype(:vpnserver) do
  @doc = "Install certificates for the openvpn server slave. 
  Copied from the master over PuppetDB"

  ensurable

  newparam(:name, :namevar => true) do
    desc "Vpnserver name"
  end 
	
  newproperty(:crt) do 
    desc "servers certificate aka server.crt"
  end

  newproperty(:key) do 
    desc "server private key aka server.key"
  end 

  newproperty(:target) do
    desc "the path for the CA crt and keys"

    defaultto {
      if
        @resource.class.defaultprovider.ancestors.include? (Puppet::Provider::ParsedFile)
        @resource.class.defaultprovider.default_target
      else
        nil
      end
     }
  end
end
end
