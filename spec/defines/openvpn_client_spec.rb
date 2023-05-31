# rubocop:disable Style/FrozenStringLiteralComment

require 'spec_helper'

describe 'openvpn::client', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:pre_condition) do
        'openvpn::server { "test_server":
          country       => "CO",
          province      => "ST",
          city          => "Some City",
          organization  => "example.org",
          email         => "testemail@example.org"
        }'
      end
      let(:facts) do
        facts
      end
      let(:title) { 'test_client' }
      let(:params) { { server: 'test_server' } }

      server_directory = case facts[:os]['family']
                         when 'CentOS', 'RedHat'
                           if facts[:os]['release']['major'] == '8'
                             '/etc/openvpn/server'
                           else
                             '/etc/openvpn'
                           end
                         else
                           '/etc/openvpn'
                         end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_exec('generate certificate for test_client in context of test_server') }

      ['test_client', 'test_client/keys/test_client'].each do |directory|
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/#{directory}") }
      end

      case facts[:os]['family']
      when 'Ubuntu', 'Debian'
        if facts[:os]['release']['major'] =~ %r{10|11|20.04|22.04}
          context 'system with easyrsa3' do
            it {
              is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/keys/test_client/test_client.crt").with(
                'ensure' => 'link',
                'target' => "#{server_directory}/test_server/easy-rsa/keys/issued/test_client.crt"
              )
            }

            it {
              is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/keys/test_client/test_client.key").with(
                'ensure' => 'link',
                'target' => "#{server_directory}/test_server/easy-rsa/keys/private/test_client.key"
              )
            }

            it {
              is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/keys/test_client/ca.crt").with(
                'ensure' => 'link',
                'target' => "#{server_directory}/test_server/easy-rsa/keys/ca.crt"
              )
            }
          end
        else
          context 'system with easyrsa2' do
            ['test_client.crt', 'test_client.key', 'ca.crt'].each do |file|
              it {
                is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/keys/test_client/#{file}").with(
                  'ensure' => 'link',
                  'target' => "#{server_directory}/test_server/easy-rsa/keys/#{file}"
                )
              }
            end
          end
        end
      when 'CentOS', 'RedHat', %r{Archlinux}, %r{FreeBSD}
        context 'system with easyrsa3' do
          it {
            is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/keys/test_client/test_client.crt").with(
              'ensure' => 'link',
              'target' => "#{server_directory}/test_server/easy-rsa/keys/issued/test_client.crt"
            )
          }

          it {
            is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/keys/test_client/test_client.key").with(
              'ensure' => 'link',
              'target' => "#{server_directory}/test_server/easy-rsa/keys/private/test_client.key"
            )
          }

          it {
            is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/keys/test_client/ca.crt").with(
              'ensure' => 'link',
              'target' => "#{server_directory}/test_server/easy-rsa/keys/ca.crt"
            )
          }
        end
      end

      it {
        is_expected.to contain_exec('tar the thing test_server with test_client').with(
          'cwd' => "#{server_directory}/test_server/download-configs/",
          'command' => '/bin/rm test_client.tar.gz; tar --exclude=\*.conf.d -chzvf test_client.tar.gz test_client test_client.tblk'
        )
      }

      context 'setting the minimum parameters' do
        let(:params) do
          {
            'server' => 'test_server',
            'remote_host' => 'foo.example.com'
          }
        end

        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^client$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^ca\s+keys/test_client/ca\.crt$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^cert\s+keys/test_client/test_client.crt$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^key\s+keys/test_client/test_client\.key$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^dev\s+tun$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^proto\s+tcp$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^remote\s+foo.example.com\s+1194$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^resolv-retry\s+infinite$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^nobind$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^persist-key$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^persist-tun$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^mute-replay-warnings$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^remote-cert-tls\s+server$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^verb\s+3$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^mute\s+20$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^auth-retry\s+none$}) }
        it { is_expected.not_to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^tls-client$}) }
        it { is_expected.not_to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^verify-x509-name}) }
        it { is_expected.not_to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^sndbuf}) }
        it { is_expected.not_to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^rcvbuf}) }
        it { is_expected.not_to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^pull}) }
      end

      context 'setting all of the parameters' do
        let(:params) do
          {
            'server' => 'test_server',
            'compression' => 'compress lz4',
            'dev' => 'tap',
            'mute' => 10,
            'mute_replay_warnings' => false,
            'nobind' => false,
            'persist_key' => false,
            'persist_tun' => false,
            'cipher' => 'AES-256-GCM',
            'tls_cipher' => 'TLS-DHE-RSA-WITH-AES-256-CBC-SHA',
            'data_ciphers' => 'AES-256-GCM',
            'data_ciphers_fallback' => 'AES-128-GCM',
            'port' => '123',
            'proto' => 'udp',
            'remote_host' => %w[somewhere galaxy],
            'resolv_retry' => '2m',
            'auth_retry' => 'interact',
            'verb' => '1',
            'setenv' => { 'CLIENT_CERT' => '0' },
            'setenv_safe' => { 'FORWARD_COMPATIBLE' => '1' },
            'tls_auth' => true,
            'x509_name' => 'test_server',
            'sndbuf' => 393_216,
            'rcvbuf' => 393_215,
            'readme' => 'readme text',
            'pull' => true,
            'remote_cert_tls' => false
          }
        end

        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^client$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^ca\s+keys/test_client/ca\.crt$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^cert\s+keys/test_client/test_client.crt$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^key\s+keys/test_client/test_client\.key$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^dev\s+tap$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^proto\s+udp$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^remote\s+somewhere\s+123$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^remote\s+galaxy\s+123$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^compress lz4$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^resolv-retry\s+2m$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^verb\s+1$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^mute\s+10$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^auth-retry\s+interact$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^setenv\s+CLIENT_CERT\s+0$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^setenv_safe\s+FORWARD_COMPATIBLE\s+1$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^cipher\s+AES-256-GCM$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^tls-cipher\s+TLS-DHE-RSA-WITH-AES-256-CBC-SHA$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^data-ciphers\s+AES-256-GCM$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^data-ciphers-fallback\s+AES-128-GCM$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^tls-client$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^verify-x509-name\s+"test_server"\s+name$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^sndbuf\s+393216$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^rcvbuf\s+393215$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/README").with_content(%r{^readme text$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^pull$}) }
        it { is_expected.not_to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^remote-cert-tls\s+server$}) }
      end

      context 'test tls_crypt' do
        let(:params) { { 'server' => 'test_server', 'tls_crypt' => true } }

        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^tls-crypt keys/test_client/ta\.key$}) }
      end

      context 'omitting the cipher key' do
        let(:params) { { 'server' => 'test_server' } }

        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^cipher AES-256-GCM$}) }
      end

      context 'should fail if specifying an openvpn::server with extca_enabled=true' do
        let(:params) do
          {
            'server' => 'test_server_extca'
          }
        end

        before do
          pre_condition << '
            openvpn::server { "text_server_extca":
              tls_auth                => true,
              extca_enabled           => true,
              extca_ca_cert_file      => "/etc/ipa/ca.crt",
              extca_ca_crl_file       => "/etc/ipa/ca_crl.pem",
              extca_server_cert_file  => "/etc/pki/tls/certs/localhost.crt",
              extca_server_key_file   => "/etc/pki/tls/private/localhost.key",
              extca_dh_file           => "/etc/ipa/dh.pem",
              extca_tls_auth_key_file => "/etc/openvpn/keys/ta.key",
            }
          '
        end

        it { expect { is_expected.to contain_file('test') }.to raise_error(Puppet::Error) }
      end

      context 'when using shared ca' do
        let(:params) do
          {
            'server' => 'test_server',
            'shared_ca' => 'my_already_existing_ca'
          }
        end

        before do
          pre_condition << '
            openvpn::server { "my_already_existing_ca":
              country       => "CO",
              province      => "ST",
              city          => "Some City",
              organization  => "example.org",
              email         => "testemail@example.org"
            }
          '
        end

        it { is_expected.to contain_openvpn__ca('my_already_existing_ca') }

        it { is_expected.to contain_exec('generate certificate for test_client in context of my_already_existing_ca') }

        # Check that certificate files point to the provided CA
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^client$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^ca\s+keys/test_client/ca\.crt$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^cert\s+keys/test_client/test_client.crt$}) }
        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^key\s+keys/test_client/test_client\.key$}) }

        case facts[:os]['family']
        when 'Ubuntu', 'Debian'
          if facts[:os]['release']['major'] =~ %r{10|11|20.04|22.04}
            context 'system with easyrsa3' do
              it {
                is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/keys/test_client/test_client.crt").with(
                  'ensure' => 'link',
                  'target' => "#{server_directory}/my_already_existing_ca/easy-rsa/keys/issued/test_client.crt"
                )
              }

              it {
                is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/keys/test_client/test_client.key").with(
                  'ensure' => 'link',
                  'target' => "#{server_directory}/my_already_existing_ca/easy-rsa/keys/private/test_client.key"
                )
              }

              it {
                is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/keys/test_client/ca.crt").with(
                  'ensure' => 'link',
                  'target' => "#{server_directory}/my_already_existing_ca/easy-rsa/keys/ca.crt"
                )
              }
            end
          else
            context 'system with easyrsa2' do
              ['test_client.crt', 'test_client.key', 'ca.crt'].each do |file|
                it {
                  is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/keys/test_client/#{file}").with(
                    'ensure' => 'link',
                    'target' => "#{server_directory}/my_already_existing_ca/easy-rsa/keys/#{file}"
                  )
                }
              end
            end
          end
        when 'CentOS', 'RedHat', %r{Archlinux}, %r{FreeBSD}
          context 'system with easyrsa3' do
            it {
              is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/keys/test_client/test_client.crt").with(
                'ensure' => 'link',
                'target' => "#{server_directory}/my_already_existing_ca/easy-rsa/keys/issued/test_client.crt"
              )
            }

            it {
              is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/keys/test_client/test_client.key").with(
                'ensure' => 'link',
                'target' => "#{server_directory}/my_already_existing_ca/easy-rsa/keys/private/test_client.key"
              )
            }

            it {
              is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/keys/test_client/ca.crt").with(
                'ensure' => 'link',
                'target' => "#{server_directory}/my_already_existing_ca/easy-rsa/keys/ca.crt"
              )
            }
          end
        end
      end

      context 'when using not existed shared ca' do
        let(:params) do
          {
            'server' => 'test_server',
            'shared_ca' => 'my_already_existing_ca'
          }
        end

        it { expect { is_expected.to contain_file('test') }.to raise_error(Puppet::Error) }
      end

      context 'custom options' do
        let(:params) do
          {
            'server' => 'test_server',
            'custom_options' => { 'this' => 'that' }
          }
        end

        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^this that$}) }
      end
    end
  end
end
# rubocop:enable Style/FrozenStringLiteralComment
