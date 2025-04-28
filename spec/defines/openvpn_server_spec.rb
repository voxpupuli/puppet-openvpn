# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn::server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          easyrsa: '3.0'
        )
      end

      let(:title) { 'test_server' }

      server_directory = case os_facts[:os]['family']
                         when 'Archlinux', 'Debian', 'RedHat'
                           '/etc/openvpn/server'
                         when 'Solaris'
                           '/opt/local/etc/openvpn'
                         when 'FreeBSD'
                           '/usr/local/etc/openvpn'
                         else
                           '/etc/openvpn'
                         end
      pam_module_path = case os_facts[:os]['family']
                        when 'RedHat'
                          case os_facts[:os]['name']
                          when 'Rocky'
                            '/usr/lib64/openvpn/plugins/openvpn-auth-pam.so'
                          else
                            '/usr/lib64/openvpn/plugin/lib/openvpn-auth-pam.so'
                          end
                        when 'Debian'
                          '/usr/lib/openvpn/openvpn-plugin-auth-pam.so'
                        when 'FreeBSD'
                          '/usr/local/lib/openvpn/openvpn-auth-pam.so'
                        when 'Archlinux'
                          '/usr/lib/openvpn/plugins/openvpn-plugin-auth-pam.so'
                        else
                          '~'
                        end
      context 'with default parameters' do
        let(:params) { {} }

        it { is_expected.to compile.and_raise_error(%r{Evaluation Error}) }
      end

      context 'with country' do
        let(:params) do
          {
            'country' => 'CO'
          }
        end

        it { is_expected.to compile.and_raise_error(%r{Evaluation Error}) }

        context 'with province' do
          let(:params) do
            {
              'country' => 'CO',
              'province' => 'ST'
            }
          end

          it { is_expected.to compile.and_raise_error(%r{Evaluation Error}) }

          context 'with city' do
            let(:params) do
              {
                'country' => 'CO',
                'province' => 'ST',
                'city' => 'Some City'
              }
            end

            it { is_expected.to compile.and_raise_error(%r{Evaluation Error}) }

            context 'with organization' do
              let(:params) do
                {
                  'country' => 'CO',
                  'province' => 'ST',
                  'city' => 'Some City',
                  'organization' => 'example.org'
                }
              end

              it { is_expected.to compile.and_raise_error(%r{Evaluation Error}) }

              context 'with email' do
                let(:params) do
                  {
                    'country' => 'CO',
                    'province' => 'ST',
                    'city' => 'Some City',
                    'organization' => 'example.org',
                    'email' => 'user@example.com'
                  }
                end

                it { is_expected.to compile.with_all_deps }
              end
            end
          end
        end
      end

      context 'with extca_enabled' do
        let(:params) do
          {
            'extca_enabled' => true
          }
        end

        it { is_expected.to compile.and_raise_error(%r{Evaluation Error}) }

        context 'with extca parameters' do
          let(:params) do
            {
              'extca_enabled' => true,
              'extca_ca_cert_file' => '/etc/ipa/ca.crt',
              'extca_ca_crl_file' => '/etc/ipa/ca_crl.pem',
              'extca_server_cert_file' => '/etc/pki/tls/certs/localhost.crt',
              'extca_server_key_file' => '/etc/pki/tls/private/localhost.key',
              'extca_dh_file' => '/etc/ipa/dh.pem'
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file("#{server_directory}/test_server.conf").
              with_content(%r{^ca\s+/etc/ipa/ca\.crt$}).
              with_content(%r{^crl-verify\s+/etc/ipa/ca_crl\.pem$}).
              with_content(%r{^cert\s+/etc/pki/tls/certs/localhost\.crt$}).
              with_content(%r{^key\s+/etc/pki/tls/private/localhost\.key$}).
              with_content(%r{^dh\s+/etc/ipa/dh\.pem$})
          }
        end

        context 'with tls_auth=true' do
          let(:params) do
            {
              'tls_auth' => true,
              'extca_enabled' => true,
              'extca_ca_cert_file' => '/etc/ipa/ca.crt',
              'extca_ca_crl_file' => '/etc/ipa/ca_crl.pem',
              'extca_server_cert_file' => '/etc/pki/tls/certs/localhost.crt',
              'extca_server_key_file' => '/etc/pki/tls/private/localhost.key',
              'extca_dh_file' => '/etc/ipa/dh.pem'
            }
          end

          it { is_expected.to compile.and_raise_error(%r{Evaluation Error}) }

          context 'with extca_tls_auth_key_file' do
            let(:params) do
              {
                'tls_auth' => true,
                'extca_tls_auth_key_file' => '/etc/openvpn/ta.key',
                'extca_enabled' => true,
                'extca_ca_cert_file' => '/etc/ipa/ca.crt',
                'extca_ca_crl_file' => '/etc/ipa/ca_crl.pem',
                'extca_server_cert_file' => '/etc/pki/tls/certs/localhost.crt',
                'extca_server_key_file' => '/etc/pki/tls/private/localhost.key',
                'extca_dh_file' => '/etc/ipa/dh.pem'
              }
            end

            it { is_expected.to compile.with_all_deps }

            it {
              is_expected.to contain_file("#{server_directory}/test_server.conf").
                with_content(%r{^ca\s+/etc/ipa/ca\.crt$}).
                with_content(%r{^crl-verify\s+/etc/ipa/ca_crl\.pem$}).
                with_content(%r{^cert\s+/etc/pki/tls/certs/localhost\.crt$}).
                with_content(%r{^key\s+/etc/pki/tls/private/localhost\.key$}).
                with_content(%r{^dh\s+/etc/ipa/dh\.pem$}).
                with_content(%r{^tls-auth\s+/etc/openvpn/ta\.key$}).
                with_content(%r{^key-direction\s+0$})
            }
          end
        end
      end

      context 'with sndbuf and rcvbuf' do
        let(:params) do
          {
            'country' => 'CO',
            'province' => 'ST',
            'city' => 'Some City',
            'organization' => 'example.org',
            'email' => 'testemail@example.org',
            'sndbuf' => 393_216,
            'rcvbuf' => 393_215
          }
        end

        it { is_expected.to contain_file("#{server_directory}/test_server.conf").with_content(%r{^sndbuf\s+393216$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server.conf").with_content(%r{^rcvbuf\s+393215$}) }
      end

      %w[udp tcp udp4 tcp4 udp6 tcp6].each do |proto|
        context "with proto=#{proto}" do
          let(:params) do
            {
              'country' => 'CO',
              'province' => 'ST',
              'city' => 'Some City',
              'organization' => 'example.org',
              'email' => 'testemail@example.org',
              'proto' => proto
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            if proto.include?('tcp')
              is_expected.to contain_file("#{server_directory}/test_server.conf").
                with_content(%r{^proto\s+#{proto}-server$})
            else
              is_expected.to contain_file("#{server_directory}/test_server.conf").
                with_content(%r{^proto\s+#{proto}$})
            end
          }
        end
      end

      context 'with invalid proto' do
        let(:params) do
          {
            'country' => 'CO',
            'province' => 'ST',
            'city' => 'Some City',
            'organization' => 'example.org',
            'email' => 'testemail@example.org',
            'proto' => 'invalid'
          }
        end

        it { is_expected.to compile.and_raise_error(%r{Evaluation Error}) }
      end

      context 'with remote' do
        let(:title) { 'test_client' }
        let(:params) do
          {
            'server_poll_timeout' => 1,
            'ping_timer_rem' => true,
            'tls_auth' => true,
            'tls_client' => true,
            'remote' => ['vpn.example.com 1194']
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file("#{server_directory}/test_client.conf").
            with_content(%r{^remote\s+vpn\.example\.com\s+1194$}).
            with_content(%r{^client$}).
            with_content(%r{^server-poll-timeout\s+1$}).
            with_content(%r{^remote-cert-tls server}).
            with_content(%r{^ping-timer-rem$}).
            with_content(%r{^tls-client$}).
            with_content(%r{^key-direction\s+1$}).
            with_content(%r{^port\s+\d+$}).
            without_content(%r{^mode\s+server$}).
            without_content(%r{^nobind$}).
            without_content(%r{^client-config-dir}).
            without_content(%r{^dh}).
            without_content(%r{^remote-random-hostname$}).
            without_content(%r{^remote-random$})
        }

        context 'with nobind' do
          let(:params) do
            {
              'server_poll_timeout' => 1,
              'ping_timer_rem' => true,
              'tls_auth' => true,
              'tls_client' => true,
              'nobind' => true,
              'remote' => ['vpn.example.com 1194']
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file("#{server_directory}/test_client.conf").
              with_content(%r{^nobind$}).
              without_content(%r{^port\s+\d+$})
          }
        end

        it { is_expected.not_to contain_openvpn__ca('test_client') }

        it { is_expected.to contain_file("#{server_directory}/test_client/keys").with(mode: '0750', ensure: 'directory') }

        it { is_expected.to contain_file("#{server_directory}/test_client/keys").with_group('nobody') } if os_facts[:os]['family'] == %r{'RedHat'|'Solaris'|'FreeBSD'}

        it { is_expected.to contain_file("#{server_directory}/test_client/keys").with_group('nogroup') } if os_facts[:os]['family'] == 'Debian'

        it { is_expected.to contain_file("#{server_directory}/test_client/keys").with_group('network') } if os_facts[:os]['family'] == 'Archlinux'

        context 'with multiple remotes' do
          let(:params) do
            {
              'server_poll_timeout' => 1,
              'ping_timer_rem' => true,
              'tls_auth' => true,
              'tls_client' => true,
              'remote' => ['vpn.example.com 1194', 'vpn2.example.com 1194']
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file("#{server_directory}/test_client.conf").
              with_content(%r{^remote\s+vpn\.example\.com\s+1194$}).
              with_content(%r{^remote\s+vpn2\.example\.com\s+1194$}).
              with_content(%r{^client$}).
              with_content(%r{^server-poll-timeout\s+1$}).
              with_content(%r{^remote-cert-tls server}).
              with_content(%r{^ping-timer-rem$}).
              with_content(%r{^tls-client$}).
              with_content(%r{^key-direction\s+1$}).
              with_content(%r{^port\s+\d+$}).
              without_content(%r{^mode\s+server$}).
              without_content(%r{^nobind$}).
              without_content(%r{^client-config-dir}).
              without_content(%r{^dh}).
              without_content(%r{^remote-random-hostname$}).
              without_content(%r{^remote-random$})
          }

          it { is_expected.not_to contain_openvpn__ca('test_client') }
          it { is_expected.to contain_file("#{server_directory}/test_client/keys").with(mode: '0750', ensure: 'directory') }

          it { is_expected.to contain_file("#{server_directory}/test_client/keys").with_group('nobody') } if os_facts[:os]['family'] == %r{'RedHat'|'Solaris'|'FreeBSD'}

          it { is_expected.to contain_file("#{server_directory}/test_client/keys").with_group('nogroup') } if os_facts[:os]['family'] == 'Debian'

          it { is_expected.to contain_file("#{server_directory}/test_client/keys").with_group('network') } if os_facts[:os]['family'] == 'Archlinux'

          context 'with remote_random' do
            let(:params) do
              {
                'server_poll_timeout' => 1,
                'ping_timer_rem' => true,
                'tls_auth' => true,
                'tls_client' => true,
                'remote_random' => true,
                'remote_random_hostname' => true,
                'remote' => ['vpn.example.com 1194', 'vpn2.example.com 1194']
              }
            end

            it { is_expected.to compile.with_all_deps }

            it {
              is_expected.to contain_file("#{server_directory}/test_client.conf").
                with_content(%r{^remote\s+vpn\.example\.com\s+1194$}).
                with_content(%r{^remote\s+vpn2\.example\.com\s+1194$}).
                with_content(%r{^client$}).
                with_content(%r{^server-poll-timeout\s+1$}).
                with_content(%r{^remote-cert-tls server}).
                with_content(%r{^ping-timer-rem$}).
                with_content(%r{^tls-client$}).
                with_content(%r{^key-direction\s+1$}).
                with_content(%r{^port\s+\d+$}).
                with_content(%r{^remote-random$}).
                with_content(%r{^remote-random-hostname$}).
                without_content(%r{^mode\s+server$}).
                without_content(%r{^nobind$}).
                without_content(%r{^client-config-dir}).
                without_content(%r{^dh})
            }

            it { is_expected.not_to contain_openvpn__ca('test_client') }
            it { is_expected.to contain_file("#{server_directory}/test_client/keys").with(mode: '0750', ensure: 'directory') }

            it { is_expected.to contain_file("#{server_directory}/test_client/keys").with_group('nobody') } if os_facts[:os]['family'] == %r{'RedHat'|'Solaris'|'FreeBSD'}

            it { is_expected.to contain_file("#{server_directory}/test_client/keys").with_group('nogroup') } if os_facts[:os]['family'] == 'Debian'

            it { is_expected.to contain_file("#{server_directory}/test_client/keys").with_group('network') } if os_facts[:os]['family'] == 'Archlinux'
          end
        end
      end

      context 'with all parameters' do
        let(:params) do
          {
            'country' => 'CO',
            'province' => 'ST',
            'city' => 'Some City',
            'organization' => 'example.org',
            'email' => 'testemail@example.org',
            'compression' => 'compress lz4',
            'port' => '123',
            'proto' => 'udp',
            'group' => 'someone',
            'user' => 'someone',
            'logfile' => '/var/log/openvpn/server1/test_server.log',
            'manage_logfile_directory' => true,
            'logdirectory_user' => 'someone',
            'logdirectory_group' => 'someone',
            'status_log' => '/tmp/test_server_status.log',
            'dev' => 'tun1',
            'up' => '/tmp/up',
            'down' => '/tmp/down',
            'client_connect' => '/tmp/connect',
            'client_disconnect' => '/tmp/disconnect',
            'local' => '2.3.4.5',
            'ipp' => true,
            'server' => '2.3.4.0 255.255.0.0',
            'server_ipv6'	=> 'fe80:1337:1337:1337::/64',
            'push' => ['dhcp-option DNS 172.31.0.30', 'route 172.31.0.0 255.255.0.0'],
            'route' => ['192.168.30.0 255.255.255.0', '192.168.35.0 255.255.0.0'],
            'route_ipv6' => ['2001:db8:1234::/64', '2001:db8:abcd::/64'],
            'keepalive' => '10 120',
            'topology' => 'subnet',
            'ssl_key_size' => 2048,
            'management' => true,
            'management_ip' => '1.3.3.7',
            'management_port' => 1337,
            'common_name' => 'mylittlepony',
            'ca_expire' => 365,
            'crl_auto_renew' => true,
            'key_expire' => 365,
            'crl_days' => 20,
            'digest' => 'sha256',
            'key_cn' => 'yolo',
            'key_name' => 'burp',
            'key_ou' => 'NSA',
            'verb' => 'mute',
            'cipher' => 'DES-CBC',
            'tls_cipher' => 'TLS-DHE-RSA-WITH-AES-256-CBC-SHA',
            'persist_key' => true,
            'persist_tun' => true,
            'duplicate_cn' => true,
            'tls_auth' => true,
            'tls_server' => true,
            'fragment' => 1412,
            'custom_options' => { 'this' => 'that' },
            'portshare' => '127.0.0.1 8443',
            'secret' => 'secretsecret1234',
            'remote_cert_tls' => true
          }
        end

        it {
          is_expected.to contain_file("#{server_directory}/test_server.conf").
            with_content(%r{^mode\s+server$}).
            with_content(%r{^client-config-dir\s+#{server_directory}/test_server/client-configs$}).
            with_content(%r{^ca\s+#{server_directory}/test_server/keys/ca.crt$}).
            with_content(%r{^proto\s+udp$}).
            with_content(%r{^port\s+123$}).
            with_content(%r{^compress lz4$}).
            with_content(%r{^log-append\s+/var/log/openvpn/server1/test_server\.log$}).
            with_content(%r{^status\s+/tmp/test_server_status\.log$}).
            with_content(%r{^dev\s+tun1$}).
            with_content(%r{^local\s+2\.3\.4\.5$}).
            with_content(%r{^server\s+2\.3\.4\.0\s+255\.255\.0\.0$}).
            with_content(%r{^server-ipv6\s+fe80:1337:1337:1337::/64$}).
            with_content(%r{^push\s+"dhcp-option\s+DNS\s+172\.31\.0\.30"$}).
            with_content(%r{^push\s+"route\s+172\.31\.0\.0\s+255\.255\.0\.0"$}).
            with_content(%r{^route\s+192.168.30.0\s+255.255.255.0$}).
            with_content(%r{^route\s+192.168.35.0\s+255.255.0.0$}).
            with_content(%r{^route-ipv6\s+2001:db8:1234::/64$}).
            with_content(%r{^route-ipv6\s+2001:db8:abcd::/64$}).
            with_content(%r{^keepalive\s+10\s+120$}).
            with_content(%r{^topology\s+subnet$}).
            with_content(%r{^management\s+1.3.3.7 1337$}).
            with_content(%r{^verb mute$}).
            with_content(%r{^cipher DES-CBC$}).
            with_content(%r{^tls-cipher\s+TLS-DHE-RSA-WITH-AES-256-CBC-SHA$}).
            with_content(%r{^persist-key$}).
            with_content(%r{^persist-tun$}).
            with_content(%r{^up "/tmp/up"$}).
            with_content(%r{^down "/tmp/down"$}).
            with_content(%r{^client-connect "/tmp/connect"$}).
            with_content(%r{^client-disconnect "/tmp/disconnect"$}).
            with_content(%r{^script-security 2$}).
            with_content(%r{^duplicate-cn$}).
            with_content(%r{^tls-server$}).
            with_content(%r{^tls-auth\s+#{server_directory}/test_server/keys/ta.key$}).
            with_content(%r{^key-direction 0$}).
            with_content(%r{^this that$}).
            with_content(%r{^fragment 1412$}).
            with_content(%r{^port-share 127.0.0.1 8443$}).
            with_content(%r{^secret #{server_directory}/test_server/keys/pre-shared.secret$}).
            without_content(%r{^proto\s+tls-server$}).
            without_content(%r{^server-poll-timeout}).
            without_content(%r{^ping-timer-rem}).
            without_content(%r{^sndbuf}).
            without_content(%r{^rcvbuf}).
            without_content(%r{^remote-cert-tls server$})
        }

        unless os_facts[:os]['family'] == 'Archlinux'
          it {
            is_expected.to contain_file("#{server_directory}/test_server.conf").
              with_content(%r{^group\s+someone$}).
              with_content(%r{^user\s+someone$})
          }
        end

        it { is_expected.to contain_file('/var/log/openvpn/server1').with(ensure: 'directory', owner: 'someone', group: 'someone') }

        it {
          is_expected.to contain_file("#{server_directory}/test_server/keys/pre-shared.secret").
            with_content(%r{^secretsecret1234$}).
            with_ensure('present')
        }

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
                 crl_days: 20,
                 digest: 'sha256',
                 key_cn: 'yolo',
                 key_name: 'burp',
                 key_ou: 'NSA',
                 tls_static_key: true)
        }
      end

      context 'with pam' do
        let(:params) do
          {
            'country' => 'CO',
            'province' => 'ST',
            'city' => 'Some City',
            'organization' => 'example.org',
            'email' => 'testmail@example.org',
            'pam' => true
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_file("#{server_directory}/test_server.conf").with_content(%r{^plugin #{pam_module_path} "?login"?$}) } unless os_facts[:os]['family'] == 'Archlinux'

        context 'with pam_module_arguments' do
          let(:params) do
            {
              'country' => 'CO',
              'province' => 'ST',
              'city' => 'Some City',
              'organization' => 'example.org',
              'email' => 'testmail@example.org',
              'pam' => true,
              'pam_module_arguments' => 'openvpn login USERNAME password PASSWORD'
            }
          end

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_file("#{server_directory}/test_server.conf").with_content(%r{^plugin #{pam_module_path} "openvpn login USERNAME password PASSWORD"$}) } unless os_facts[:os]['family'] == 'Archlinux'
        end
      end

      if os_facts[:os]['family'] == 'Debian'
        context 'with ldap authentication' do
          let(:params) do
            {
              'country' => 'CO',
              'province' => 'ST',
              'city' => 'Some City',
              'organization' => 'example.org',
              'email' => 'testemail@example.org',
              'ldap_enabled' => true,
              'ldap_binddn' => 'dn=foo,ou=foo,ou=com',
              'ldap_bindpass' => 'ldappass123',
              'ldap_tls_enable' => true,
              'ldap_tls_ca_cert_file' => '/etc/ldap/ca.pem',
              'ldap_tls_ca_cert_dir' => '/etc/ldap/certs'
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file("#{server_directory}/test_server/auth/ldap.conf").
              with_content(%r{^\s+TLSEnable\s+yes$}).
              with_content(%r{^\s+TLSCACertFile\s+/etc/ldap/ca.pem$}).
              with_content(%r{^\s+TLSCACertDir\s+/etc/ldap/certs$}).
              without_content(%r{^\s+TLSCertFile.*$}).
              without_content(%r{^\s+TLSKeyFile.*$})
          }

          context 'with ldap_tls_cert_file and ldap_tls_key_file' do
            let(:params) do
              {
                'country' => 'CO',
                'province' => 'ST',
                'city' => 'Some City',
                'organization' => 'example.org',
                'email' => 'testemail@example.org',
                'ldap_enabled' => true,
                'ldap_binddn' => 'dn=foo,ou=foo,ou=com',
                'ldap_bindpass' => 'ldappass123',
                'ldap_tls_enable' => true,
                'ldap_tls_ca_cert_file' => '/etc/ldap/ca.pem',
                'ldap_tls_ca_cert_dir' => '/etc/ldap/certs',
                'ldap_tls_client_cert_file' => '/etc/ldap/client-cert.pem',
                'ldap_tls_client_key_file' => '/etc/ldap/client-key.pem'
              }
            end

            it {
              is_expected.to contain_file("#{server_directory}/test_server/auth/ldap.conf").
                with_content(%r{^\s+TLSEnable\s+yes$}).
                with_content(%r{^\s+TLSCACertFile\s+/etc/ldap/ca.pem$}).
                with_content(%r{^\s+TLSCACertDir\s+/etc/ldap/certs$}).
                with_content(%r{^\s+TLSCertFile\s+/etc/ldap/client-cert.pem$}).
                with_content(%r{^\s+TLSKeyFile\s+/etc/ldap/client-key.pem$})
            }
          end
        end
      end
    end
  end
end
