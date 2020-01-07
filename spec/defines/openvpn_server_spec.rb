require 'spec_helper'

describe 'openvpn::server' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:title) { 'test_server' }

      # common tests for any easyrsa version
      context 'creating a server without any parameter' do
        let(:params) { {} }

        it { expect { is_expected.to contain_file('/etc/openvpn/test_server') }.to raise_error(Puppet::PreformattedError) }
      end

      context 'creating a server partial parameters: country' do
        let(:params) { { 'country' => 'CO' } }

        it { expect { is_expected.to contain_file('/etc/openvpn/test_server') }.to raise_error(Puppet::PreformattedError) }
      end

      context 'creating a server partial parameters: country, province' do
        let(:params) do
          {
            'country' => 'CO',
            'province' => 'ST'
          }
        end

        it { expect { is_expected.to contain_file('/etc/openvpn/test_server') }.to raise_error(Puppet::PreformattedError) }
      end

      context 'creating a server partial parameters: country, province, city' do
        let(:params) do
          {
            'country'       => 'CO',
            'province'      => 'ST',
            'city'          => 'Some City'
          }
        end

        it { expect { is_expected.to contain_file('/etc/openvpn/test_server') }.to raise_error(Puppet::PreformattedError) }
      end

      context 'creating a server partial parameters: country, province, city, organization' do
        let(:params) do
          {
            'country'       => 'CO',
            'province'      => 'ST',
            'city'          => 'Some City',
            'organization'  => 'example.org'
          }
        end

        it { expect { is_expected.to contain_file('/etc/openvpn/test_server') }.to raise_error(Puppet::PreformattedError) }
      end

      context 'when using not existed shared ca' do
        let(:params) do
          {
            'shared_ca' => 'my_already_existing_ca'
          }
        end

        it { expect { is_expected.to contain_file('/etc/openvpn/test_server') }.to raise_error(Puppet::PreformattedError) }
      end

      context 'should fail if setting extca_enabled=true without specifying any other extca_* options' do
        let(:params) do
          {
            'extca_enabled' => true
          }
        end

        it { expect { is_expected.to contain_file('/etc/openvpn/test_server') }.to raise_error(Puppet::PreformattedError) }
      end

      context 'should fail if setting extca_enabled=true and tls_auth=true without providing extca_tls_auth_key_file' do
        let(:params) do
          {
            'tls_auth' => true,
            'extca_enabled'           => true,
            'extca_ca_cert_file'      => '/etc/ipa/ca.crt',
            'extca_ca_crl_file'       => '/etc/ipa/ca_crl.pem',
            'extca_server_cert_file'  => '/etc/pki/tls/certs/localhost.crt',
            'extca_server_key_file'   => '/etc/pki/tls/private/localhost.key',
            'extca_dh_file'           => '/etc/ipa/dh.pem'
          }
        end

        it { expect { is_expected.to contain_file('/etc/openvpn/test_server') }.to raise_error(Puppet::PreformattedError) }
      end

      context 'when altering send and receive buffers' do
        let(:params) do
          {
            'country' => 'CO',
            'province'      => 'ST',
            'city'          => 'Some City',
            'organization'  => 'example.org',
            'email'         => 'testemail@example.org',
            'sndbuf'        => 393_216,
            'rcvbuf'        => 393_215
          }
        end

        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^sndbuf\s+393216$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^rcvbuf\s+393215$}) }
      end

      context 'when using udp4' do
        let(:params) do
          {
            'country'       => 'CO',
            'province'      => 'ST',
            'city'          => 'Some City',
            'organization'  => 'example.org',
            'email'         => 'testemail@example.org',
            'proto'         => 'udp4'
          }
        end

        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^proto\s+udp4$}) }
      end

      context 'when using udp6' do
        let(:params) do
          {
            'country'       => 'CO',
            'province'      => 'ST',
            'city'          => 'Some City',
            'organization'  => 'example.org',
            'email'         => 'testemail@example.org',
            'proto'         => 'udp6'
          }
        end

        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^proto\s+udp6$}) }
      end

      context 'when using tcp4' do
        let(:params) do
          {
            'country'       => 'CO',
            'province'      => 'ST',
            'city'          => 'Some City',
            'organization'  => 'example.org',
            'email'         => 'testemail@example.org',
            'proto'         => 'tcp4'
          }
        end

        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^proto\s+tcp4-server$}) }
      end

      context 'when using tcp6' do
        let(:params) do
          {
            'country'       => 'CO',
            'province'      => 'ST',
            'city'          => 'Some City',
            'organization'  => 'example.org',
            'email'         => 'testemail@example.org',
            'proto'         => 'tcp6'
          }
        end

        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^proto\s+tcp6-server$}) }
      end

      context 'when using invalid value for proto' do
        let(:params) do
          {
            'country'       => 'CO',
            'province'      => 'ST',
            'city'          => 'Some City',
            'organization'  => 'example.org',
            'email'         => 'testemail@example.org',
            'proto'         => 'tcp5'
          }
        end

        it { expect { is_expected.to contain_file('/etc/openvpn/test_server') }.to raise_error(Puppet::PreformattedError) }
      end

      context 'creating a server in client mode' do
        let(:title) { 'test_client' }
        let(:nobind) { false }
        let(:params) do
          {
            'remote' => ['vpn.example.com 12345'],
            'server_poll_timeout' => 1,
            'ping_timer_rem'      => true,
            'tls_auth'            => true,
            'tls_client'          => true,
            'nobind'              => nobind
          }
        end

        context 'nobind is true' do
          let(:nobind) { true }

          it { is_expected.to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^nobind$}) }
          it { is_expected.not_to contain_file('/etc/openvpn/test_client.conf').with_content(%r{port\s+\d+}) }
        end

        it { is_expected.to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^client$}) }
        it {
          is_expected.to contain_file('/etc/openvpn/test_client.conf').
            with_content(%r{^remote\s+vpn.example.com\s+12345$})
        }
        it { is_expected.to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^server-poll-timeout\s+1$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^ping-timer-rem$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^ns-cert-type server}) }
        it { is_expected.not_to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^mode\s+server$}) }
        it { is_expected.not_to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^client-config-dir}) }
        it { is_expected.not_to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^dh}) }
        it { is_expected.to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^tls-client$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^key-direction 1$}) }
        it { is_expected.not_to contain_file('/etc/openvpn/test_client.conf').with_content(%r{nobind}) }
        it { is_expected.to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^port\s+\d+$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_client.conf').without_content(%r{^remote-random-hostname$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_client.conf').without_content(%r{^remote-random$}) }

        it { is_expected.not_to contain_openvpn__ca('test_client') }

        case facts[:os]['family']
        when 'RedHat'
          it {
            is_expected.to contain_file('/etc/openvpn/test_client/keys').
              with(ensure: 'directory', mode: '0750', group: 'nobody')
          }
        end
      end

      context 'creating a server in client mode with multiple remotes and random' do
        let(:title) { 'test_client' }
        let(:nobind) { false }
        let(:params) do
          {
            'remote' => ['vpn1.example.com 12345', 'vpn2.example.com 23456'],
            'remote_random_hostname' => true,
            'remote_random'          => true,
            'server_poll_timeout'    => 1,
            'ping_timer_rem'         => true,
            'tls_auth'               => true,
            'tls_client'             => true,
            'nobind'                 => nobind
          }
        end

        it { is_expected.to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^client$}) }
        it {
          is_expected.to contain_file('/etc/openvpn/test_client.conf').
            with_content(%r{^remote\s+vpn1.example.com\s+12345$})
        }
        it {
          is_expected.to contain_file('/etc/openvpn/test_client.conf').
            with_content(%r{^remote\s+vpn2.example.com\s+23456$})
        }
        it { is_expected.to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^remote-random-hostname$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^remote-random$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^server-poll-timeout\s+1$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^ping-timer-rem$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^ns-cert-type server}) }
        it { is_expected.not_to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^mode\s+server$}) }
        it { is_expected.not_to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^client-config-dir}) }
        it { is_expected.not_to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^dh}) }
        it { is_expected.to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^tls-client$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^key-direction 1$}) }
        it { is_expected.not_to contain_file('/etc/openvpn/test_client.conf').with_content(%r{nobind}) }
        it { is_expected.to contain_file('/etc/openvpn/test_client.conf').with_content(%r{^port\s+\d+$}) }

        it { is_expected.not_to contain_openvpn__ca('test_client') }

        case facts[:os]['family']
        when 'RedHat'
          it {
            is_expected.to contain_file('/etc/openvpn/test_client/keys').
              with(ensure: 'directory', mode: '0750', group: 'nobody')
          }
        end
      end

      case facts[:os]['family']
      when 'Debian'
        # ldap auth needs the ldap package and that is only defined for a few OSes (including debian)
        context 'debian' do
          context 'creating a server with ldap authentication enabled' do
            let(:params) do
              {
                'country'               => 'CO',
                'province'              => 'ST',
                'city'                  => 'Some City',
                'organization'          => 'example.org',
                'email'                 => 'testemail@example.org',
                'ldap_enabled'          => true,
                'ldap_binddn'           => 'dn=foo,ou=foo,ou=com',
                'ldap_bindpass'         => 'ldappass123',
                'ldap_tls_enable'       => true,
                'ldap_tls_ca_cert_file' => '/etc/ldap/ca.pem',
                'ldap_tls_ca_cert_dir'  => '/etc/ldap/certs'
              }
            end

            it { is_expected.to contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+TLSEnable\s+yes$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+TLSCACertFile\s+/etc/ldap/ca.pem$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+TLSCACertDir\s+/etc/ldap/certs$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server/auth/ldap.conf').without_content(%r{^\s+TLSCertFile.*$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server/auth/ldap.conf').without_content(%r{^\s+TLSKeyFile.*$}) }
          end

          context 'creating a server with ldap authentication enabled and using ldap client certificates' do
            let(:params) do
              {
                'country'                   => 'CO',
                'province'                  => 'ST',
                'city'                      => 'Some City',
                'organization'              => 'example.org',
                'email'                     => 'testemail@example.org',
                'ldap_enabled'              => true,
                'ldap_binddn'               => 'dn=foo,ou=foo,ou=com',
                'ldap_bindpass'             => 'ldappass123',
                'ldap_tls_enable'           => true,
                'ldap_tls_ca_cert_file'     => '/etc/ldap/ca.pem',
                'ldap_tls_ca_cert_dir'      => '/etc/ldap/certs',
                'ldap_tls_client_cert_file' => '/etc/ldap/client-cert.pem',
                'ldap_tls_client_key_file'  => '/etc/ldap/client-key.pem'
              }
            end

            it { is_expected.to contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+TLSEnable\s+yes$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+TLSCACertFile\s+/etc/ldap/ca.pem$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+TLSCACertDir\s+/etc/ldap/certs$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+TLSCertFile\s+/etc/ldap/client-cert.pem$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+TLSKeyFile\s+/etc/ldap/client-key.pem$}) }
          end
        end
      end

      context 'creating a server setting all parameters' do
        let(:params) do
          {
            'country'           => 'CO',
            'province'          => 'ST',
            'city'              => 'Some City',
            'organization'      => 'example.org',
            'email'             => 'testemail@example.org',
            'compression'       => 'compress lz4',
            'port'              => '123',
            'proto'             => 'udp',
            'group'             => 'someone',
            'user'              => 'someone',
            'logfile'           => '/var/log/openvpn/server1/test_server.log',
            'manage_logfile_directory' => true,
            'logdirectory_user'        => 'someone',
            'logdirectory_group'       => 'someone',
            'status_log'        => '/tmp/test_server_status.log',
            'dev'               => 'tun1',
            'up'                => '/tmp/up',
            'down'              => '/tmp/down',
            'client_connect'    => '/tmp/connect',
            'client_disconnect' => '/tmp/disconnect',
            'local'             => '2.3.4.5',
            'ipp'               => true,
            'server'            => '2.3.4.0 255.255.0.0',
            'server_ipv6'	=> 'fe80:1337:1337:1337::/64',
            'push'              => ['dhcp-option DNS 172.31.0.30', 'route 172.31.0.0 255.255.0.0'],
            'route'             => ['192.168.30.0 255.255.255.0', '192.168.35.0 255.255.0.0'],
            'route_ipv6'        => ['2001:db8:1234::/64', '2001:db8:abcd::/64'],
            'keepalive'         => '10 120',
            'topology'          => 'subnet',
            'ssl_key_size'      => 2048,
            'management'        => true,
            'management_ip'     => '1.3.3.7',
            'management_port'   => 1337,
            'common_name'       => 'mylittlepony',
            'ca_expire'         => 365,
            'crl_auto_renew'    => true,
            'key_expire'        => 365,
            'key_cn'            => 'yolo',
            'key_name'          => 'burp',
            'key_ou'            => 'NSA',
            'verb'              => 'mute',
            'cipher'            => 'DES-CBC',
            'tls_cipher'        => 'TLS-DHE-RSA-WITH-AES-256-CBC-SHA',
            'persist_key'       => true,
            'persist_tun'       => true,
            'duplicate_cn'      => true,
            'tls_auth'          => true,
            'tls_server'        => true,
            'fragment'          => 1412,
            'custom_options'    => { 'this' => 'that' },
            'portshare'         => '127.0.0.1 8443',
            'secret'            => 'secretsecret1234',
            'remote_cert_tls'   => true
          }
        end

        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^mode\s+server$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^client-config-dir\s+/etc/openvpn/test_server/client-configs$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^ca\s+/etc/openvpn/test_server/keys/ca.crt$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^proto\s+udp$}) }
        it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^proto\s+tls-server$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^port\s+123$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^compress lz4$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^group\s+someone$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^user\s+someone$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^log\-append\s+/var/log/openvpn/server1/test_server\.log$}) }
        it { is_expected.to contain_file('/var/log/openvpn/server1').with('ensure' => 'directory', 'owner' => 'someone', 'group' => 'someone') }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^status\s+/tmp/test_server_status\.log$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^dev\s+tun1$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^local\s+2\.3\.4\.5$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^server\s+2\.3\.4\.0\s+255\.255\.0\.0$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^server-ipv6\s+fe80:1337:1337:1337::/64$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^push\s+"dhcp-option\s+DNS\s+172\.31\.0\.30"$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^push\s+"route\s+172\.31\.0\.0\s+255\.255\.0\.0"$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^route\s+192.168.30.0\s+255.255.255.0$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^route\s+192.168.35.0\s+255.255.0.0$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^route-ipv6\s+2001:db8:1234::/64$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^route-ipv6\s+2001:db8:abcd::/64$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^keepalive\s+10\s+120$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^topology\s+subnet$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^management\s+1.3.3.7 1337$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^verb mute$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^cipher DES-CBC$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^tls-cipher\s+TLS-DHE-RSA-WITH-AES-256-CBC-SHA$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^persist-key$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^persist-tun$}) }

        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^up "/tmp/up"$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^down "/tmp/down"$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^client-connect "/tmp/connect"$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^client-disconnect "/tmp/disconnect"$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^script-security 2$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^duplicate-cn$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^tls-server$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^tls-auth\s+/etc/openvpn/test_server/keys/ta.key$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^key-direction 0$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^this that$}) }

        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^fragment 1412$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^port-share 127.0.0.1 8443$}) }
        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^secret /etc/openvpn/test_server/keys/pre-shared.secret$}) }

        it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^server-poll-timeout}) }
        it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^ping-timer-rem}) }
        it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^sndbuf}) }
        it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^rcvbuf}) }
        it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^remote-cert-tls server$}) }

        it { is_expected.to contain_file('/etc/openvpn/test_server/keys/pre-shared.secret').with_content(%r{^secretsecret1234$}).with(ensure: 'present') }
        it { is_expected.to contain_schedule('renew crl.pem schedule on test_server') }
        it { is_expected.to contain_exec('renew crl.pem on test_server') }

        # OpenVPN easy-rsa CA
        it {
          is_expected.to contain_openvpn__ca('test_server').
            with(country: 'CO',
                 province: 'ST',
                 city: 'Some City',
                 organization: 'example.org',
                 email: 'testemail@example.org',
                 group: 'someone',
                 ssl_key_size: 2048,
                 common_name: 'mylittlepony',
                 ca_expire: 365,
                 key_expire: 365,
                 key_cn: 'yolo',
                 key_name: 'burp',
                 key_ou: 'NSA',
                 tls_static_key: true)
        }
      end

      context 'creating a server setting all parameters including tls_crypt' do
        let(:params) do
          {
            'country'       => 'CO',
            'province'      => 'ST',
            'city'          => 'Some City',
            'organization'  => 'example.org',
            'email'         => 'testemail@example.org',
            'proto'         => 'tcp6',
            'tls_crypt'     => true
          }
        end

        it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^tls-crypt\s+/etc/openvpn/test_server/keys/ta.key$}) }

        # OpenVPN easy-rsa CA
        it { is_expected.to contain_openvpn__ca('test_server').with(tls_static_key: true) }
      end

      # tests dedicated to easyrsa version 2
      context 'with easyrsa 2.0' do
        let(:facts) do
          facts.merge(
            easyrsa: '2.0'
          )
        end

        context 'creating a server setting all parameters' do
          let(:params) do
            {
              'country' => 'CO',
              'province'        => 'ST',
              'city'            => 'Some City',
              'organization'    => 'example.org',
              'email'           => 'testemail@example.org',
              'compression'     => 'compress lz4',
              'port'            => '123',
              'proto'           => 'udp',
              'group'           => 'someone',
              'user'            => 'someone',
              'logfile'         => '/var/log/openvpn/test_server.log',
              'status_log'      => '/tmp/test_server_status.log',
              'dev'             => 'tun1',
              'up'              => '/tmp/up',
              'down'            => '/tmp/down',
              'local'           => '2.3.4.5',
              'ipp'             => true,
              'server'          => '2.3.4.0 255.255.0.0',
              'server_ipv6'	=> 'fe80:1337:1337:1337::/64',
              'push'            => ['dhcp-option DNS 172.31.0.30', 'route 172.31.0.0 255.255.0.0'],
              'route'           => ['192.168.30.0 255.255.255.0', '192.168.35.0 255.255.0.0'],
              'route_ipv6'      => ['2001:db8:1234::/64', '2001:db8:abcd::/64'],
              'keepalive'       => '10 120',
              'topology'        => 'subnet',
              'ssl_key_size'    => 2048,
              'management'      => true,
              'management_ip'   => '1.3.3.7',
              'management_port' => 1337,
              'common_name'     => 'mylittlepony',
              'ca_expire'       => 365,
              'crl_auto_renew'  => true,
              'key_expire'      => 365,
              'key_cn'          => 'yolo',
              'key_name'        => 'burp',
              'key_ou'          => 'NSA',
              'verb'            => 'mute',
              'cipher'          => 'DES-CBC',
              'tls_cipher'      => 'TLS-DHE-RSA-WITH-AES-256-CBC-SHA',
              'persist_key'     => true,
              'persist_tun'     => true,
              'duplicate_cn'    => true,
              'tls_auth'        => true,
              'tls_server'      => true,
              'fragment'        => 1412,
              'custom_options'  => { 'this' => 'that' },
              'portshare'       => '127.0.0.1 8443',
              'secret'          => 'secretsecret1234',
              'remote_cert_tls' => true
            }
          end

          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^cert\s+/etc/openvpn/test_server/keys/mylittlepony.crt$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^key\s+/etc/openvpn/test_server/keys/mylittlepony.key$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^dh\s+/etc/openvpn/test_server/keys/dh2048.pem$}) }
        end

        context 'creating a server in client mode' do
          let(:title) { 'test_client' }
          let(:nobind) { false }
          let(:params) do
            {
              'remote' => ['vpn.example.com 12345'],
              'server_poll_timeout' => 1,
              'ping_timer_rem'      => true,
              'tls_auth'            => true,
              'tls_client'          => true,
              'nobind'              => nobind
            }
          end

          it {
            is_expected.to contain_file('/etc/openvpn/test_client.conf').
              with_content(%r{^ca /etc/openvpn/test_client/keys/ca.crt$})
          }
          it {
            is_expected.to contain_file('/etc/openvpn/test_client.conf').
              with_content(%r{^cert /etc/openvpn/test_client/keys/test_client.crt$})
          }
          it {
            is_expected.to contain_file('/etc/openvpn/test_client.conf').
              with_content(%r{^key /etc/openvpn/test_client/keys/test_client.key$})
          }
        end

        context 'when using shared ca' do
          let(:params) do
            {
              'shared_ca' => 'my_already_existing_ca'
            }
          end
          let(:pre_condition) do
            '
            openvpn::ca{ "my_already_existing_ca":
                common_name   => "custom_common_name",
                country       => "CO",
                province      => "ST",
                city          => "Some City",
                organization  => "example.org",
                email         => "testemail@example.org"
          }'
          end

          it { is_expected.to contain_openvpn__ca('my_already_existing_ca') }

          # Check that certificate files point to the provide CA

          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^mode\s+server$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^client\-config\-dir\s+\/etc\/openvpn\/test_server\/client\-configs$}) }

          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^ca\s+\/etc\/openvpn\/my_already_existing_ca\/keys\/ca.crt$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^cert\s+\/etc\/openvpn\/my_already_existing_ca\/keys\/custom_common_name.crt$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^key\s+\/etc\/openvpn\/my_already_existing_ca\/keys\/custom_common_name.key$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^dh\s+\/etc\/openvpn\/my_already_existing_ca\/keys\/dh2048.pem$}) }
        end
        context 'creating a server with the minimum parameters' do
          let(:params) do
            {
              'country'       => 'CO',
              'province'      => 'ST',
              'city'          => 'Some City',
              'organization'  => 'example.org',
              'email'         => 'testemail@example.org'
            }
          end

          # OpenVPN easy-rsa CA
          it { is_expected.to contain_openvpn__ca('test_server').with(params) }

          # VPN server config file itself

          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^mode\s+server$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^client\-config\-dir\s+\/etc\/openvpn\/test_server\/client\-configs$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^ca\s+\/etc\/openvpn\/test_server\/keys\/ca.crt$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^cert\s+\/etc\/openvpn\/test_server\/keys\/server.crt$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^key\s+\/etc\/openvpn\/test_server\/keys\/server.key$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^dh\s+\/etc\/openvpn\/test_server\/keys\/dh2048.pem$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^proto\s+tcp-server$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^tls-server$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^port\s+1194$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^comp-lzo$}) }
          it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^log\-append\s+test_server\/openvpn\.log$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^status\s+/var/log/openvpn/test_server-status\.log$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^dev\s+tun0$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^local\s+10\.0\.2\.15$}) }
          it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^ifconfig-pool-persist}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^crl-verify\s+\/etc\/openvpn\/test_server\/crl.pem$}) }
          it { is_expected.not_to contain_schedule('renew crl.pem schedule on test_server') }
          it { is_expected.not_to contain_exec('renew crl.pem on test_server') }
          it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^secret}) }

          it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{verb}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{cipher AES-256-CBC}) }
          it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{persist-key}) }
          it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{persist-tun}) }
          it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^duplicate-cn$}) }
          it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^ns-cert-type server}) }
          it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^tls-auth}) }
          it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^fragment}) }
          it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^port-share}) }

          it { is_expected.to contain_file('/etc/openvpn/test_server/keys/pre-shared.secret').with(ensure: 'absent') }
        end

        context 'when pushing scripts' do
          let(:params) do
            {
              'country'           => 'CO',
              'province'          => 'ST',
              'city'              => 'Some City',
              'organization'      => 'example.org',
              'email'             => 'testemail@example.org',
              'up'                => 'up.sh',
              'down'              => 'down.sh',
              'client_connect'    => 'connect.sh',
              'client_disconnect' => 'disconnect.sh',
              'scripts'           => {
                'add-tap-to-bridge.sh' => {
                  'ensure' => 'present'
                }
              }
            }
          end

          it { is_expected.to contain_file('/etc/openvpn/test_server/scripts/add-tap-to-bridge.sh').with(ensure: 'present') }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^up\s+"/etc/openvpn/test_server/scripts/up\.sh"$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^down\s+"/etc/openvpn/test_server/scripts/down\.sh"$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^client\-connect\s+"/etc/openvpn/test_server/scripts/connect\.sh"$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^client\-disconnect\s+"/etc/openvpn/test_server/scripts/disconnect\.sh"$}) }
        end

        context 'when not using scripts' do
          let(:params) do
            {
              'country'           => 'CO',
              'province'          => 'ST',
              'city'              => 'Some City',
              'organization'      => 'example.org',
              'email'             => 'testemail@example.org'
            }
          end

          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').without_content(%r{^script-security\s+}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').without_content(%r{^up\s+}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').without_content(%r{^down\s+}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').without_content(%r{^client\-connect\s+}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').without_content(%r{^client\-disconnect\s+}) }
        end

        case facts[:os]['family']
        when %r{FreeBSD}
          context 'when FreeBSD based machine' do
            let(:params) do
              {
                'country' => 'CO',
                'province'      => 'ST',
                'city'          => 'Some City',
                'organization'  => 'example.org',
                'email'         => 'testemail@example.org',
                'pam'           => true
              }
            end

            it { is_expected.to contain_file('/etc/rc.conf.d/openvpn_test_server') }
            it { is_expected.to contain_service('openvpn_test_server') }
            it { is_expected.to contain_file('/usr/local/etc/openvpn/test_server') }
            it { is_expected.to contain_file('/usr/local/etc/rc.d/openvpn_test_server') }
            it { is_expected.to contain_file('/usr/local/etc/openvpn/test_server.conf').with_content(%r{/usr/local/etc}) }
          end
          context 'creating a server with the minimum parameters' do
            let(:params) do
              {
                'country'       => 'CO',
                'province'      => 'ST',
                'city'          => 'Some City',
                'organization'  => 'example.org',
                'email'         => 'testemail@example.org'
              }
            end

            # Files associated with a server config
            it {
              is_expected.to contain_file('/etc/openvpn/test_server').
                with(ensure: 'directory', mode: '0750', group: 'nogroup')
            }
            it {
              is_expected.to contain_file('/etc/openvpn/test_server/client-configs').
                with(ensure: 'directory', mode: '0750', recurse: true, group: 'nogroup')
            }
            it {
              is_expected.to contain_file('/etc/openvpn/test_server/download-configs').
                with(ensure: 'directory', mode: '0750', recurse: true, group: 'nogroup')
            }
            it {
              is_expected.to contain_file('/etc/openvpn/test_server/auth').
                with(ensure: 'directory', mode: '0750', recurse: true, group: 'nogroup')
            }
            it {
              is_expected.to contain_file('/etc/openvpn/test_server/scripts').
                with(ensure: 'directory', mode: '0750', recurse: true, group: 'nogroup')
            }

            # VPN server config file itself

            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^group\s+nogroup$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^user\s+nobody$}) }
          end

        when 'Debian'
          context 'creating a server with the minimum parameters' do
            let(:params) do
              {
                'country'       => 'CO',
                'province'      => 'ST',
                'city'          => 'Some City',
                'organization'  => 'example.org',
                'email'         => 'testemail@example.org'
              }
            end

            # Files associated with a server config
            it {
              is_expected.to contain_file('/etc/openvpn/test_server').
                with(ensure: 'directory', mode: '0750', group: 'nogroup')
            }
            it {
              is_expected.to contain_file('/etc/openvpn/test_server/client-configs').
                with(ensure: 'directory', mode: '0750', recurse: true, group: 'nogroup')
            }
            it {
              is_expected.to contain_file('/etc/openvpn/test_server/download-configs').
                with(ensure: 'directory', mode: '0750', recurse: true, group: 'nogroup')
            }
            it {
              is_expected.to contain_file('/etc/openvpn/test_server/auth').
                with(ensure: 'directory', mode: '0750', recurse: true, group: 'nogroup')
            }
            it {
              is_expected.to contain_file('/etc/openvpn/test_server/scripts').
                with(ensure: 'directory', mode: '0750', recurse: true, group: 'nogroup')
            }

            # VPN server config file itself

            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^group\s+nogroup$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^user\s+nobody$}) }
          end

          context 'when Debian based machine' do
            let(:params) do
              {
                'country' => 'CO',
                'province'      => 'ST',
                'city'          => 'Some City',
                'organization'  => 'example.org',
                'email'         => 'testemail@example.org',
                'pam'           => true
              }
            end

            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^group\s+nogroup$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so "login"$}) }

            context 'enabled autostart_all' do
              let(:pre_condition) { 'class { "openvpn": autostart_all => true }' }

              it { is_expected.not_to contain_concat__fragment('openvpn.default.autostart.test_server') }
            end

            context 'disabled autostart_all' do
              let(:pre_condition) { 'class { "openvpn": autostart_all => false }' }

              it { is_expected.not_to contain_concat__fragment('openvpn.default.autostart.test_server') }

              context 'but machine has autostart' do
                before { params['autostart'] = true }
                it {
                  is_expected.to contain_concat__fragment('openvpn.default.autostart.test_server').with(
                    'content' => "AUTOSTART=\"$AUTOSTART test_server\"\n",
                    'target'  => '/etc/default/openvpn'
                  )
                }
              end
            end
          end
        end
      end

      # tests with easyrsa version 3
      context 'with easyrsa 3.0' do
        let(:facts) do
          facts.merge(
            easyrsa: '3.0'
          )
        end

        context 'creating a server setting all parameters' do
          let(:params) do
            {
              'country' => 'CO',
              'province'        => 'ST',
              'city'            => 'Some City',
              'organization'    => 'example.org',
              'email'           => 'testemail@example.org',
              'compression'     => 'compress lz4',
              'port'            => '123',
              'proto'           => 'udp',
              'group'           => 'someone',
              'user'            => 'someone',
              'logfile'         => '/var/log/openvpn/test_server.log',
              'status_log'      => '/tmp/test_server_status.log',
              'dev'             => 'tun1',
              'up'              => '/tmp/up',
              'down'            => '/tmp/down',
              'local'           => '2.3.4.5',
              'ipp'             => true,
              'server'          => '2.3.4.0 255.255.0.0',
              'server_ipv6'	=> 'fe80:1337:1337:1337::/64',
              'push'            => ['dhcp-option DNS 172.31.0.30', 'route 172.31.0.0 255.255.0.0'],
              'route'           => ['192.168.30.0 255.255.255.0', '192.168.35.0 255.255.0.0'],
              'route_ipv6'      => ['2001:db8:1234::/64', '2001:db8:abcd::/64'],
              'keepalive'       => '10 120',
              'topology'        => 'subnet',
              'ssl_key_size'    => 2048,
              'management'      => true,
              'management_ip'   => '1.3.3.7',
              'management_port' => 1337,
              'common_name'     => 'mylittlepony',
              'ca_expire'       => 365,
              'crl_auto_renew'  => true,
              'key_expire'      => 365,
              'key_cn'          => 'yolo',
              'key_name'        => 'burp',
              'key_ou'          => 'NSA',
              'verb'            => 'mute',
              'cipher'          => 'DES-CBC',
              'tls_cipher'      => 'TLS-DHE-RSA-WITH-AES-256-CBC-SHA',
              'persist_key'     => true,
              'persist_tun'     => true,
              'duplicate_cn'    => true,
              'tls_auth'        => true,
              'tls_server'      => true,
              'fragment'        => 1412,
              'custom_options'  => { 'this' => 'that' },
              'portshare'       => '127.0.0.1 8443',
              'secret'          => 'secretsecret1234',
              'remote_cert_tls' => true
            }
          end

          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^cert\s+/etc/openvpn/test_server/keys/issued/mylittlepony.crt$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^key\s+/etc/openvpn/test_server/keys/private/mylittlepony.key$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^dh\s+/etc/openvpn/test_server/keys/dh.pem$}) }
        end

        context 'creating a server in client mode' do
          let(:title) { 'test_client' }
          let(:nobind) { false }
          let(:params) do
            {
              'remote' => ['vpn.example.com 12345'],
              'server_poll_timeout' => 1,
              'ping_timer_rem'      => true,
              'tls_auth'            => true,
              'tls_client'          => true,
              'nobind'              => nobind
            }
          end

          it {
            is_expected.to contain_file('/etc/openvpn/test_client.conf').
              with_content(%r{^ca /etc/openvpn/test_client/keys/ca.crt$})
          }
          it {
            is_expected.to contain_file('/etc/openvpn/test_client.conf').
              with_content(%r{^cert /etc/openvpn/test_client/keys/issued/test_client.crt$})
          }
          it {
            is_expected.to contain_file('/etc/openvpn/test_client.conf').
              with_content(%r{^key /etc/openvpn/test_client/keys/private/test_client.key$})
          }
        end

        context 'when using shared ca' do
          let(:params) do
            {
              'shared_ca' => 'my_already_existing_ca'
            }
          end
          let(:pre_condition) do
            '
            openvpn::ca{ "my_already_existing_ca":
                common_name   => "custom_common_name",
                country       => "CO",
                province      => "ST",
                city          => "Some City",
                organization  => "example.org",
                email         => "testemail@example.org"
          }'
          end

          it { is_expected.to contain_openvpn__ca('my_already_existing_ca') }

          # Check that certificate files point to the provide CA

          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^mode\s+server$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^client\-config\-dir\s+\/etc\/openvpn\/test_server\/client\-configs$}) }

          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^ca\s+\/etc\/openvpn\/my_already_existing_ca\/keys\/ca.crt$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^cert\s+\/etc\/openvpn\/my_already_existing_ca\/keys\/issued/custom_common_name.crt$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^key\s+\/etc\/openvpn\/my_already_existing_ca\/keys\/private\/custom_common_name.key$}) }
          it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^dh\s+\/etc\/openvpn\/my_already_existing_ca\/keys\/dh.pem$}) }
        end

        case facts[:os]['family']
        when 'RedHat'
          context 'creating a server with the minimum parameters' do
            let(:params) do
              {
                'country'       => 'CO',
                'province'      => 'ST',
                'city'          => 'Some City',
                'organization'  => 'example.org',
                'email'         => 'testemail@example.org'
              }
            end

            # Files associated with a server config
            it {
              is_expected.to contain_file('/etc/openvpn/test_server').
                with(ensure: 'directory', mode: '0750', group: 'nobody')
            }
            it {
              is_expected.to contain_file('/etc/openvpn/test_server/client-configs').
                with(ensure: 'directory', mode: '0750', recurse: true, group: 'nobody')
            }
            it {
              is_expected.to contain_file('/etc/openvpn/test_server/download-configs').
                with(ensure: 'directory', mode: '0750', recurse: true, group: 'nobody')
            }
            it {
              is_expected.to contain_file('/etc/openvpn/test_server/auth').
                with(ensure: 'directory', mode: '0750', recurse: true, group: 'nobody')
            }
            it {
              is_expected.to contain_file('/etc/openvpn/test_server/scripts').
                with(ensure: 'directory', mode: '0750', recurse: true, group: 'nobody')
            }

            # VPN server config file itself

            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^group\s+nobody$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^user\s+nobody$}) }
          end

          context 'RedHat using an external CA and enabling tls-auth' do
            let(:params) do
              {
                'tls_auth' => true,
                'extca_enabled'           => true,
                'extca_ca_cert_file'      => '/etc/ipa/ca.crt',
                'extca_ca_crl_file'       => '/etc/ipa/ca_crl.pem',
                'extca_server_cert_file'  => '/etc/pki/tls/certs/localhost.crt',
                'extca_server_key_file'   => '/etc/pki/tls/private/localhost.key',
                'extca_dh_file'           => '/etc/ipa/dh.pem',
                'extca_tls_auth_key_file' => '/etc/openvpn/keys/ta.key'
              }
            end

            it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^ca\s+\/etc\/openvpn\/test_server\/keys\/ca.crt$}) }
            it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^crl-verify\s+\/etc\/openvpn\/test_server\/crl.pem$}) }
            it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^cert\s+\/etc\/openvpn\/test_server\/keys\/server.crt$}) }
            it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^key\s+\/etc\/openvpn\/test_server\/keys\/server.key$}) }
            it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^dh\s+\/etc\/openvpn\/test_server\/keys\/dh2048.pem$}) }
            it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^tls-auth\s+\/etc\/openvpn\/test_server\/keys\/ta.key$}) }

            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^ca\s+/etc/ipa/ca.crt$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^crl-verify\s+/etc/ipa/ca_crl.pem$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^cert\s+/etc/pki/tls/certs/localhost.crt$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^key\s+/etc/pki/tls/private/localhost.key$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^dh\s+/etc/ipa/dh.pem$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^tls-auth\s+/etc/openvpn/keys/ta.key$}) }
          end

          context 'RedHat using an external CA and without tls-auth' do
            let(:params) do
              {
                'extca_enabled' => true,
                'extca_ca_cert_file'      => '/etc/ipa/ca.crt',
                'extca_ca_crl_file'       => '/etc/ipa/ca_crl.pem',
                'extca_server_cert_file'  => '/etc/pki/tls/certs/localhost.crt',
                'extca_server_key_file'   => '/etc/pki/tls/private/localhost.key',
                'extca_dh_file'           => '/etc/ipa/dh.pem',
                'extca_tls_auth_key_file' => '/etc/openvpn/keys/ta.key'
              }
            end

            it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^ca\s+/etc/openvpn/test_server/keys}) }
            it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^crl-verify\s+/etc/openvpn/test_server}) }
            it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^cert\s+/etc/openvpn/test_server/keys}) }
            it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^key\s+/etc/openvpn/test_server/keys}) }
            it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^dh\s+/etc/openvpn/test_server/keys}) }
            it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^tls-auth}) }

            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^ca\s+/etc/ipa/ca.crt$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^crl-verify\s+/etc/ipa/ca_crl.pem$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^cert\s+/etc/pki/tls/certs/localhost.crt$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^key\s+/etc/pki/tls/private/localhost.key$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^dh\s+/etc/ipa/dh.pem$}) }
          end

          context 'when RedHat based machine with different pam_module_arguments and crl_verify disabled' do
            let(:params) do
              {
                'country' => 'CO',
                'province'             => 'ST',
                'city'                 => 'Some City',
                'organization'         => 'example.org',
                'email'                => 'testemail@example.org',
                'pam'                  => true,
                'pam_module_arguments' => 'openvpn login USERNAME password PASSWORD',
                'crl_verify'           => false
              }
            end

            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^plugin /usr/lib64/openvpn/plugin/lib/openvpn-auth-pam.so "openvpn login USERNAME password PASSWORD"$}) }
            it { is_expected.not_to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^crl-verify}) }
          end

          context 'when RedHat based machine' do
            let(:params) do
              {
                'country' => 'CO',
                'province'      => 'ST',
                'city'          => 'Some City',
                'organization'  => 'example.org',
                'email'         => 'testemail@example.org',
                'pam'           => true
              }
            end

            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^group\s+nobody$}) }
            it { is_expected.to contain_file('/etc/openvpn/test_server.conf').with_content(%r{^plugin /usr/lib64/openvpn/plugin/lib/openvpn-auth-pam.so "?login"?$}) }
          end
        end
      end
    end
  end
end
