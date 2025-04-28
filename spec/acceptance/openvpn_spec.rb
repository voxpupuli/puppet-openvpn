# frozen_string_literal: true

require 'spec_helper_acceptance'

case fact('osfamily')
when 'RedHat'
  server_directory = '/etc/openvpn/server'
  client_directory = '/etc/openvpn/client'
  client_service = 'openvpn-client'
  server_crt = "#{server_directory}/test_openvpn_server/easy-rsa/keys/issued/server.crt"
  key_path = "#{server_directory}/test_openvpn_server/easy-rsa/keys/private"
  crt_path = "#{server_directory}/test_openvpn_server/easy-rsa/keys/issued"
  index_path = "#{server_directory}/test_openvpn_server/easy-rsa/keys"
  easy_rsa_version = '3.0'
  renew_crl_cmd = "cd #{server_directory}/test_openvpn_server/easy-rsa && . ./vars && EASYRSA_REQ_CN='' EASYRSA_REQ_OU='' openssl ca -gencrl -out #{server_directory}/test_openvpn_server/crl.pem -config #{server_directory}/test_openvpn_server/easy-rsa/openssl.cnf"
when 'Debian'
  server_directory = '/etc/openvpn/server'
  client_directory = '/etc/openvpn/client'
  client_service = 'openvpn'
  if fact('os.release.major') =~ %r{11|12|20.04|22.04}
    server_crt = "#{server_directory}/test_openvpn_server/easy-rsa/keys/issued/server.crt"
    key_path = "#{server_directory}/test_openvpn_server/easy-rsa/keys/private"
    crt_path = "#{server_directory}/test_openvpn_server/easy-rsa/keys/issued"
    easy_rsa_version = '3.0'
    renew_crl_cmd = "cd #{server_directory}/test_openvpn_server/easy-rsa && . ./vars && EASYRSA_REQ_CN='' EASYRSA_REQ_OU='' openssl ca -gencrl -out #{server_directory}/test_openvpn_server/crl.pem -config #{server_directory}/test_openvpn_server/easy-rsa/openssl.cnf"
  else
    server_crt = "#{server_directory}/test_openvpn_server/easy-rsa/keys/server.crt"
    key_path = "#{server_directory}/test_openvpn_server/easy-rsa/keys"
    crt_path = "#{server_directory}/test_openvpn_server/easy-rsa/keys"
    easy_rsa_version = '2.0'
    renew_crl_cmd = "cd #{server_directory}/test_openvpn_server/easy-rsa && . ./vars && KEY_CN='' KEY_OU='' KEY_NAME='' KEY_ALTNAMES='' openssl ca -gencrl -out #{server_directory}/test_openvpn_server/crl.pem -config #{server_directory}/test_openvpn_server/easy-rsa/openssl.cnf"
  end
  index_path = "#{server_directory}/test_openvpn_server/easy-rsa/keys"
else
  raise "Unknown OS family #{fact('osfamily')}"
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

    it 'revokes openvpn client certificate' do
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

        openvpn::client { 'vpnclientb' :
          server      => 'test_openvpn_server',
          require     => Openvpn::Server['test_openvpn_server'],
          remote_host => $facts['networking']['ip'],
          tls_cipher  => 'TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA',
        }

        openvpn::revoke { 'vpnclientb':
          server => 'test_openvpn_server',
        }
      )
      apply_manifest_on(hosts_as('vpnserver'), pp, catch_failures: true)
      apply_manifest_on(hosts_as('vpnserver'), pp, catch_changes: false)
    end

    describe file("#{server_directory}/test_openvpn_server/easy-rsa/revoked/vpnclientb"), :revokedFile do
      it { is_expected.to be_file }
    end

    describe file("#{server_directory}/test_openvpn_server/easy-rsa/keys") do
      it { is_expected.to be_directory }
    end

    describe file("#{server_directory}/test_openvpn_server/easy-rsa/vars") do
      it { is_expected.to be_file }
      it { is_expected.to contain "export EASY_RSA=\"#{server_directory}/test_openvpn_server/easy-rsa\"" }
      it { is_expected.to contain '_COUNTRY="CO"' }
      it { is_expected.to contain '_PROVINCE="ST"' }
      it { is_expected.to contain '_CITY="A city"' }
      it { is_expected.to contain '_ORG="FOO"' }
      it { is_expected.to contain '_EMAIL="bar@foo.org"' }
    end

    describe file(server_crt.to_s), :crtFile do
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

    describe file("#{server_directory}/test_openvpn_server/download-configs/vpnclienta.tar.gz") do
      it { is_expected.to be_file }
      its(:size) { is_expected.to be > 500 }
    end

    it 'permits to setup a vpn client' do
      scp_from(hosts_as('vpnserver'), "#{server_directory}/test_openvpn_server/download-configs/vpnclienta.tar.gz", '.')
      scp_to(hosts_as('vpnclienta'), 'vpnclienta.tar.gz', '/tmp')
      on(hosts_as('vpnclienta'), "tar xvfz /tmp/vpnclienta.tar.gz -C #{client_directory}")
      on(hosts_as('vpnclienta'), "cp -a #{client_directory}/vpnclienta/* #{client_directory}/")
      on(hosts_as('vpnclienta'), "systemctl enable #{client_service}@vpnclienta")
      on(hosts_as('vpnclienta'), "systemctl restart #{client_service}@vpnclienta")
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

if easy_rsa_version == '3.0'
  describe 'server defined type w/ easy-rsa 3.0' do
    dev = 'tun1'
    server_name = 'test_openvpn_server_ec_dn_mode'
    port = 1195
    management_port = 7506

    context 'with basics parameters' do
      it 'installs openvpn server idempotently' do
        pp = %(
        openvpn::server { '#{server_name}':
          dev             => '#{dev}',
          dn_mode         => 'cn_only',
          ssl_key_algo    => 'ec',
          ssl_key_curve   => 'secp521r1',
          ecdh_curve      => 'secp521r1',
          digest          => 'sha256',
          common_name     => 'openvpn-server',
          server          => '10.1.0.0 255.255.255.0',
          port            => '#{port}',
          management      => true,
          management_port => #{management_port},
          tls_cipher      => 'TLS-ECDHE-ECDSA-WITH-AES-256-GCM-SHA384',
        }
      )
        apply_manifest_on(hosts_as('vpnserver'), pp, catch_failures: true)
        apply_manifest_on(hosts_as('vpnserver'), pp, catch_changes: true)
      end

      it 'creates openvpn client certificate idempotently' do
        pp = %(
        openvpn::server { '#{server_name}':
          dev             => '#{dev}',
          dn_mode         => 'cn_only',
          ssl_key_algo    => 'ec',
          ssl_key_curve   => 'secp521r1',
          ecdh_curve      => 'secp521r1',
          digest          => 'sha256',
          common_name     => 'openvpn-server',
          server          => '10.1.0.0 255.255.255.0',
          port            => '#{port}',
          management      => true,
          management_port => #{management_port},
          tls_cipher      => 'TLS-ECDHE-ECDSA-WITH-AES-256-GCM-SHA384',
        }

        openvpn::client { '#{server_name}-vpnclienta' :
          server      => '#{server_name}',
          port        => '#{port}',
          require     => Openvpn::Server['#{server_name}'],
          remote_host => $facts['networking']['ip'],
          tls_cipher  => 'TLS-ECDHE-ECDSA-WITH-AES-256-GCM-SHA384',
        }
      )
        apply_manifest_on(hosts_as('vpnserver'), pp, catch_failures: true)
        apply_manifest_on(hosts_as('vpnserver'), pp, catch_changes: true)
      end

      it 'revokes openvpn client certificate' do
        pp = %(
        openvpn::server { '#{server_name}':
          dev             => '#{dev}',
          dn_mode         => 'cn_only',
          ssl_key_algo    => 'ec',
          ssl_key_curve   => 'secp521r1',
          ecdh_curve      => 'secp521r1',
          digest          => 'sha256',
          common_name     => 'openvpn-server',
          server          => '10.1.0.0 255.255.255.0',
          port            => '#{port}',
          management      => true,
          management_port => #{management_port},
          tls_cipher      => 'TLS-ECDHE-ECDSA-WITH-AES-256-GCM-SHA384',
        }

        openvpn::client { '#{server_name}-vpnclientb' :
          server      => '#{server_name}',
          port        => '#{port}',
          require     => Openvpn::Server['#{server_name}'],
          remote_host => $facts['networking']['ip'],
          tls_cipher  => 'TLS-ECDHE-ECDSA-WITH-AES-256-GCM-SHA384',
        }

        openvpn::revoke { '#{server_name}-vpnclientb':
          server => '#{server_name}',
        }
      )
        apply_manifest_on(hosts_as('vpnserver'), pp, catch_failures: true)
        apply_manifest_on(hosts_as('vpnserver'), pp, catch_changes: false)
      end

      describe file("#{server_directory}/#{server_name}/easy-rsa/revoked/#{server_name}-vpnclientb"), :revokedFile do
        it { is_expected.to be_file }
      end

      describe file("#{server_directory}/#{server_name}/easy-rsa/keys") do
        it { is_expected.to be_directory }
      end

      describe file("#{server_directory}/#{server_name}/easy-rsa/vars") do
        it { is_expected.to be_file }
        it { is_expected.to contain 'export EASYRSA_ALGO=ec' }
        it { is_expected.to contain 'export EASYRSA_CURVE=secp521r1' }
        it { is_expected.to contain 'export EASYRSA_DIGEST=sha256' }
        it { is_expected.to contain 'export EASYRSA_DN="cn_only"' }
      end

      describe file(server_crt.to_s), :crtFile do
        it { is_expected.to be_file }
        it { is_expected.to contain 'Issuer: C=CO, ST=ST, L=A city, O=FOO, ' }
      end

      describe process('openvpn') do
        it { is_expected.to be_running }
      end

      describe port(port) do
        it { is_expected.to be_listening.with('tcp') }
      end

      describe command("ip link show #{dev}") do
        its(:stdout) { is_expected.to match %r{.* #{dev}: .*} }
        its(:exit_status) { is_expected.to eq 0 }
      end

      describe file("#{server_directory}/#{server_name}/easy-rsa/keys/private/#{server_name}-vpnclienta.key") do
        it { is_expected.to be_file }
      end

      describe file("#{server_directory}/#{server_name}/easy-rsa/keys/issued/#{server_name}-vpnclienta.crt") do
        it { is_expected.to be_file }
        it { is_expected.to contain 'Issuer: CN=openvpn-server CA' }
      end

      describe file("#{server_directory}/#{server_name}/easy-rsa/keys/index.txt") do
        it { is_expected.to be_file }
        it { is_expected.to contain "CN=#{server_name}-vpnclienta" }
      end

      describe file("#{server_directory}/#{server_name}/download-configs/#{server_name}-vpnclienta.tar.gz") do
        it { is_expected.to be_file }
        its(:size) { is_expected.to be > 500 }
      end

      it 'permits to setup a vpn client' do
        scp_from(hosts_as('vpnserver'), "#{server_directory}/#{server_name}/download-configs/#{server_name}-vpnclienta.tar.gz", '.')
        scp_to(hosts_as('vpnclienta'), "#{server_name}-vpnclienta.tar.gz", '/tmp')
        on(hosts_as('vpnclienta'), "tar xvfz /tmp/#{server_name}-vpnclienta.tar.gz -C #{client_directory}")
        on(hosts_as('vpnclienta'), "cp -a #{client_directory}/#{server_name}-vpnclienta/* #{client_directory}/")
        on(hosts_as('vpnclienta'), "systemctl enable #{client_service}@#{server_name}-vpnclienta")
        on(hosts_as('vpnclienta'), "systemctl restart #{client_service}@#{server_name}-vpnclienta")
      end

      it 'logs (in case of an error)' do
        on(hosts_as('vpnserver'), "journalctl -lu #{client_service}@#{server_name}")
        on(hosts_as('vpnclienta'), "journalctl -lu #{client_service}@#{server_name}-vpnclienta")
      end

      describe command("echo status |nc -w 1 localhost #{management_port}") do
        its(:stdout) { is_expected.to match %r{.*#{server_name}-vpnclienta.*} }
        its(:exit_status) { is_expected.to eq 0 }
      end

      describe command(renew_crl_cmd.to_s) do
        its(:exit_status) { is_expected.to eq 0 }
      end
    end
  end
end
