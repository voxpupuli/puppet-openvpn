require 'facter'

if File.directory?('/etc/openvpn/')
openvpn_clients = Dir['/etc/openvpn/*/easy-rsa/keys/*.crt'].map { |a| a.gsub(%r{\.crt$}, '').gsub(%r{^.*/}, '') }
openvpn_ca = Dir.entries('/etc/openvpn').select {|entry| File.directory? File.join('/etc/openvpn',entry) and !(entry =='.' || entry == '..' || entry == 'keys') }


Facter.add(:openvpn_clients) do
  setcode do
    openvpn_clients.join(',') if openvpn_clients
  end
end

Facter.add(:openvpn_ca) do
  setcode do
    openvpn_ca.first if openvpn_ca
  end
end

Facter.add('openvpn_crt_ca') do
  setcode do
    crt = File.read("/etc/openvpn/#{openvpn_ca.first}/easy-rsa/keys/ca.crt")
    crt
  end
end

Facter.add('openvpn_key_ca') do
  setcode do
    key = File.read("/etc/openvpn/#{openvpn_ca.first}/easy-rsa/keys/ca.key")
    key
  end
end

openvpn_clients.each do |openvpn_client|
  Facter.add('openvpn_crt_' + openvpn_client) do
    setcode do
      crt = File.read("/etc/openvpn/#{openvpn_ca.first}/easy-rsa/keys/#{openvpn_client}.crt")
      crt
    end
  end
end

openvpn_clients.each do |openvpn_client|
  Facter.add('openvpn_key_' + openvpn_client) do
    setcode do
      key = File.read("/etc/openvpn/#{openvpn_ca.first}/easy-rsa/keys/#{openvpn_client}.key")
      key
    end
  end
end
end
