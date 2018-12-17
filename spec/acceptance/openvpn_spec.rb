require 'spec_helper_acceptance'

case fact('osfamily')
when 'RedHat'
  server_crt = '/etc/openvpn/test_openvpn_server/easy-rsa/keys/issued/server.crt'
  key_path = '/etc/openvpn/test_openvpn_server/easy-rsa/keys/private'
  crt_path = '/etc/openvpn/test_openvpn_server/easy-rsa/keys/issued'
  index_path = '/etc/openvpn/test_openvpn_server/easy-rsa/keys'
  renew_crl_cmd = "cd /etc/openvpn/test_openvpn_server/easy-rsa && . ./vars && EASYRSA_REQ_CN='' EASYRSA_REQ_OU='' openssl ca -gencrl -out /etc/openvpn/test_openvpn_server/crl.pem -config /etc/openvpn/test_openvpn_server/easy-rsa/openssl.cnf"
when 'Debian'
  server_crt = '/etc/openvpn/test_openvpn_server/easy-rsa/keys/server.crt'
  key_path = '/etc/openvpn/test_openvpn_server/easy-rsa/keys'
  crt_path = '/etc/openvpn/test_openvpn_server/easy-rsa/keys'
  index_path = '/etc/openvpn/test_openvpn_server/easy-rsa/keys'
  renew_crl_cmd = "cd /etc/openvpn/test_openvpn_server/easy-rsa && . ./vars && KEY_CN='' KEY_OU='' KEY_NAME='' KEY_ALTNAMES='' openssl ca -gencrl -out /etc/openvpn/test_openvpn_server/crl.pem -config /etc/openvpn/test_openvpn_server/easy-rsa/openssl.cnf"
end

# All-terrain tls ciphers are used to be able to work with all supported OSes.
# Default value is with ciphers too recent for old OSes like ubuntu 14.04.
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
          management   => true,
          tls_cipher   => 'TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA',
	}
      )
      apply_manifest_on(hosts_as('vpnserver'), pp, catch_failures: true)
      apply_manifest_on(hosts_as('vpnserver'), pp, catch_changes: true)
    end
    it 'creates openvpn client certificate idempotently' do
      pp = %(
        openvpn::server { 'test_openvpn_server':
          country      => 'CO',
          province     => 'ST',
          city         => 'A city',
          organization => 'FOO',
          email        => 'bar@foo.org',
          server       => '10.0.0.0 255.255.255.0',
          local        => '',
          management   => true,
          tls_cipher   => 'TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA',
        }

	openvpn::client { 'vpnclienta' :
          server      => 'test_openvpn_server',
          require     => Openvpn::Server['test_openvpn_server'],
          remote_host => $facts['networking']['ip'],
          tls_cipher  => 'TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA',
        }
      )
      apply_manifest_on(hosts_as('vpnserver'), pp, catch_failures: true)
      apply_manifest_on(hosts_as('vpnserver'), pp, catch_changes: true)
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

    describe file("#{key_path}/vpnclienta.key") do
      it { is_expected.to be_file }
    end

    describe file("#{crt_path}/vpnclienta.crt") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'Issuer: C=CO, ST=ST, L=A city, O=FOO, ' }
    end

    describe file("#{index_path}/index.txt") do
      it { is_expected.to be_file }
      it { is_expected.to contain 'CN=vpnclienta' }
    end

    describe file('/etc/openvpn/test_openvpn_server/download-configs/vpnclienta.tar.gz') do
      it { is_expected.to be_file }
      its(:size) { is_expected.to be > 500 }
    end

    it 'permits to setup a vpn client' do
      scp_from(hosts_as('vpnserver'), '/etc/openvpn/test_openvpn_server/download-configs/vpnclienta.tar.gz', '.')
      scp_to(hosts_as('vpnclienta'), 'vpnclienta.tar.gz', '/tmp')
      on(hosts_as('vpnclienta'), 'tar xvfz /tmp/vpnclienta.tar.gz -C /etc/openvpn')
      on(hosts_as('vpnclienta'), 'mv /etc/openvpn/vpnclienta/* /etc/openvpn/')
      on(hosts_as('vpnclienta'), 'systemctl enable openvpn@vpnclienta')
      on(hosts_as('vpnclienta'), 'systemctl restart openvpn@vpnclienta')
    end

    describe command('echo status |nc -w 1 localhost 7505') do
      its(:stdout) { is_expected.to match %r{.*vpnclienta.*} }
      its(:exit_status) { is_expected.to eq 0 }
    end

    describe command(renew_crl_cmd.to_s) do
      its(:exit_status) { is_expected.to eq 0 }
    end
  end
end
