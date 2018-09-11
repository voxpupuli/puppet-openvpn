require 'spec_helper_acceptance'

case fact('osfamily')
when 'RedHat'
  server_crt = '/etc/openvpn/test_openvpn_server/easy-rsa/keys/issued/server.crt'
when 'Debian'
  server_crt = '/etc/openvpn/test_openvpn_server/easy-rsa/keys/server.crt'
end

describe 'server defined type' do
  context 'with basics parameters' do
    it 'installs openvpn server idempotently' do
      pp = %(
        openvpn::server { 'test_openvpn_server':
          country      => 'CO',
          province     => 'ST',
          city         => 'A city',
          organization => 'FOO',
          email        => 'bar@foo.org',
          server       => '10.0.0.0 255.255.255.0',
          local        => '',
        }
      )
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file('/etc/openvpn/test_openvpn_server/easy-rsa/keys') do
      it { is_expected.to be_directory }
    end

    describe file('/etc/openvpn/test_openvpn_server/easy-rsa/vars') do
      it { is_expected.to be_file }
      it { is_expected.to contain 'export EASY_RSA="/etc/openvpn/test_openvpn_server/easy-rsa"' }
      it { is_expected.to contain '_COUNTRY="CO"' }
      it { is_expected.to contain '_PROVINCE="ST"' }
      it { is_expected.to contain '_CITY="A city"' }
      it { is_expected.to contain '_ORG="FOO"' }
      it { is_expected.to contain '_EMAIL="bar@foo.org"' }
    end

    describe file(server_crt.to_s) do
      it { is_expected.to be_file }
      it { is_expected.to contain 'Issuer: C=CO, ST=ST, L=A city, O=FOO, ' }
    end

    describe process('openvpn') do
      it { is_expected.to be_running }
    end

    describe port(1194) do
      it { is_expected.to be_listening.with('tcp') }
    end

    describe command('ip link show tun0') do
      its(:stdout) { is_expected.to match %r{.* tun0: .*} }
      its(:exit_status) { is_expected.to eq 0 }
    end
  end
end
