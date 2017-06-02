Puppet::Type.newtype :openvpn_server, :is_capability => true do
  newparam :name, :namevar => true
  newparam :crt
  newparam :key
end
