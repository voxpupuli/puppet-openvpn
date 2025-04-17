# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'openvpn', order: :defined do
  describe 'openvpn::server', order: :defined do
    describe 'with minimal parameters' do
      it_behaves_like 'an idempotent resource', 'master' do
        let(:manifest) do
          <<-PUPPET
          openvpn::server { 'test_openvpn_server':
            country      => 'CO',
            province     => 'ST',
            city         => 'A city',
            organization => 'FOO',
            email        => 'bar@foo.org',
            server       => '10.0.0.0 255.255.255.0',
          }
          PUPPET
        end
      end

      ['/etc/openvpn/server/test_openvpn_server',
       '/etc/openvpn/server/test_openvpn_server/keys'].each do |dir|
        describe file(dir) do
          it { is_expected.to be_directory }
        end
      end

      describe file('/etc/openvpn/server/test_openvpn_server.conf') do
        it { is_expected.to be_file }
      end

      describe service('openvpn-server@test_openvpn_server') do
        it { is_expected.to be_enabled }
        it { is_expected.to be_running }
      end

      describe port(1194) do
        it { is_expected.to be_listening }
      end

      describe file('/etc/openvpn/server/test_openvpn_server/easy-rsa/vars') do
        it { is_expected.to be_file }
        its(:content) { is_expected.to contain(%r{EASYRSA_REQ_COUNTRY "CO"}) }
        its(:content) { is_expected.to contain(%r{EASYRSA_REQ_PROVINCE "ST"}) }
        its(:content) { is_expected.to contain(%r{EASYRSA_REQ_CITY "A city"}) }
        its(:content) { is_expected.to contain(%r{EASYRSA_REQ_ORG "FOO"}) }
      end
    end
  end

  describe 'openvpn::client', order: :defined do
    it_behaves_like 'an idempotent resource', 'master' do
      let(:manifest) do
        <<-PUPPET
            openvpn::server { 'test_openvpn_server':
              country      => 'CO',
              province     => 'ST',
              city         => 'A city',
              organization => 'FOO',
              email        => 'bar@foo.org',
              server       => '10.0.0.0 255.255.255.0',
            }
            openvpn::client { ['vpnclienta','vpnclientb'] :
              server      => 'test_openvpn_server',
              require     => Openvpn::Server['test_openvpn_server'],
            }
        PUPPET
      end
    end

    ['/etc/openvpn/server/test_openvpn_server/download-configs/vpnclienta.ovpn',
     '/etc/openvpn/server/test_openvpn_server/download-configs/vpnclientb.ovpn',
     '/etc/openvpn/server/test_openvpn_server/keys/private/vpnclienta.key',
     '/etc/openvpn/server/test_openvpn_server/keys/private/vpnclientb.key',
     '/etc/openvpn/server/test_openvpn_server/keys/issued/vpnclienta.crt',
     '/etc/openvpn/server/test_openvpn_server/keys/issued/vpnclientb.crt'].each do |path|
      describe file(path) do
        it { is_expected.to be_file }
      end
    end
  end

  describe 'openvpn::revoke', order: :defined do
    it 'revoke a client certificate' do
      pp = <<-PUPPET
          openvpn::server { 'test_openvpn_server':
            country      => 'CO',
            province     => 'ST',
            city         => 'A city',
            organization => 'FOO',
            email        => 'bar@foo.org',
            server       => '10.0.0.0 255.255.255.0',
          }
          openvpn::client { ['vpnclienta','vpnclientb'] :
            server      => 'test_openvpn_server',
            require     => Openvpn::Server['test_openvpn_server'],
          }
          openvpn::revoke { 'vpnclientb':
            server => 'test_openvpn_server',
          }
      PUPPET
      # Apply the manifest to revoke the client certificate
      apply_manifest_on(hosts_as('master'), pp, catch_failures: true)
    end

    describe file('/etc/openvpn/server/test_openvpn_server/easy-rsa/revoked/vpnclientb') do
      it { is_expected.to be_file }
    end
  end

  describe 'remote client', order: :defined do
    it 'connects to vpnserver' do
      scp_from(hosts_as('master'), '/etc/openvpn/server/test_openvpn_server/download-configs/vpnclienta.tar.gz', '.')
      scp_to(hosts_as('agent'), 'vpnclienta.tar.gz', '/tmp')
      on(hosts_as('agent'), 'tar xvfz /tmp/vpnclienta.tar.gz -C /etc/openvpn/client')
      on(hosts_as('agent'), 'cp -a /etc/openvpn/client/vpnclienta/* /etc/openvpn/client/')
      on(hosts_as('agent'), 'systemctl enable openvpn-client@vpnclienta')
      on(hosts_as('agent'), 'systemctl restart openvpn-client@vpnclienta')
    end
  end
end
