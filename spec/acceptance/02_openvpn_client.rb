require 'spec_helper_acceptance'

case fact('osfamily')
when 'RedHat'
  key_path = '/etc/openvpn/test_openvpn_server/easy-rsa/keys/private'
  crt_path = '/etc/openvpn/test_openvpn_server/easy-rsa/keys/issued'
  index_path = '/etc/openvpn/test_openvpn_server/easy-rsa/keys'
when 'Debian'
  key_path = '/etc/openvpn/test_openvpn_server/easy-rsa/keys'
  crt_path = '/etc/openvpn/test_openvpn_server/easy-rsa/keys'
  index_path = '/etc/openvpn/test_openvpn_server/easy-rsa/keys'
end

describe 'client defined type' do
  context 'with basics parameters' do
    it 'configure openvpn client idempotently' do
      pp = %(
        openvpn::server { 'test_openvpn_server':
          country      => 'CO',
          province     => 'ST',
          city         => 'A city',
          organization => 'FOO',
          email        => 'bar@foo.org',
          server       => '10.0.0.0 255.255.255.0',
          local        => undef,
        }

        -> openvpn::client { 'client1' :
          server  => 'test_openvpn_server',
        }
      )
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file("#{key_path}/client1.key") do
      it { is_expected.to be_file }
    end

    describe file("#{crt_path}/client1.crt") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'Issuer: C=CO, ST=ST, L=A city, O=FOO, ' }
    end

    describe file("#{index_path}/index.txt") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'CN=client1' }
    end
  end
end
