# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn::client' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          easyrsa: '3.0'
        )
      end
      let(:pre_condition) do
        'openvpn::server { "test_server":
          country       => "CO",
          province      => "ST",
          city          => "Some City",
          organization  => "example.org",
          email         => "testemail@example.org"
        }'
      end
      let(:title) { 'test_client' }

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
      context 'with default parameters' do
        let(:params) { { server: 'test_server' } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('openvpn') }

        it { is_expected.to contain_exec('generate certificate for test_client in context of test_server') }

        ['test_client', 'test_client/keys/test_client'].each do |directory|
          it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/#{directory}") }
        end
        it {
          is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").
            with_content(%r{^client$}).
            with_content(%r{^dev\s+tun$}).
            with_content(%r{^proto\s+tcp$}).
            with_content(%r{^remote\s+.+\s+1194$}).
            with_content(%r{^nobind$}).
            with_content(%r{^persist-key$}).
            with_content(%r{^persist-tun$}).
            with_content(%r{^cipher\s+AES-256-GCM$}).
            with_content(%r{^tls-cipher\s+TLS-DHE-RSA-WITH-AES-256-GCM-SHA384:TLS-DHE-RSA-WITH-AES-256-CBC-SHA256:TLS-DHE-RSA-WITH-AES-128-GCM-SHA256:TLS-DHE-RSA-WITH-AES-128-CBC-SHA256$}).
            with_content(%r{^mute-replay-warnings$}).
            with_content(%r{^remote-cert-tls\s+server$}).
            with_content(%r{^verb\s+3$}).
            with_content(%r{^mute\s+20$}).
            with_content(%r{^ca\s+keys/test_client/ca\.crt$}).
            with_content(%r{^cert\s+keys/test_client/test_client.crt$}).
            with_content(%r{^key\s+keys/test_client/test_client\.key$}).
            without_content(%r{^pull$}).
            without_content(%r{^sndbuf}).
            without_content(%r{^rcvbuf}).
            without_content(%r{^auth-user-pass}).
            without_content(%r{^setnev}).
            without_content(%r{^setnev-safe}).
            without_content(%r{^script-security\s+2$}).
            without_content(%r{^up}).
            without_content(%r{^down}).
            without_content(%r{^x509-verify-name})
        }

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

      context 'with remote_host' do
        let(:params) do
          {
            'server' => 'test_server',
            'remote_host' => 'foo.example.com'
          }
        end

        it {
          is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").
            with_content(%r{^client$}).
            with_content(%r{^dev\s+tun$}).
            with_content(%r{^proto\s+tcp$}).
            with_content(%r{^remote\s+foo.example.com\s+1194$})
        }

        it {
          is_expected.not_to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").
            with_content(%r{^tls-client$}).
            with_content(%r{^verify-x509-name}).
            with_content(%r{^sndbuf}).
            with_content(%r{^rcvbuf}).
            with_content(%r{^pull})
        }
      end

      context 'with tls_crypt true' do
        let(:params) { { 'server' => 'test_server', 'tls_crypt' => true } }

        it {
          is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").
            with_content(%r{^tls-crypt\s+keys/test_client/ta\.key$})
        }
      end

      context 'with tls_auth true' do
        let(:params) { { 'server' => 'test_server', 'tls_auth' => true } }

        it {
          is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").
            with_content(%r{^tls-client$}).
            with_content(%r{^tls-auth\s+keys/test_client/ta\.key\s+1$})
        }
      end

      context 'with tls_auth and tls_crypt true' do
        let(:params) { { 'server' => 'test_server', 'tls_auth' => true, 'tls_crypt' => true } }

        it { is_expected.to compile.and_raise_error(%r{tls_auth and tls_crypt are mutually exclusive}) }
      end

      context 'with authuserpass true' do
        let(:params) { { 'server' => 'test_server', 'authuserpass' => true } }

        it {
          is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").
            with_content(%r{^auth-user-pass$})
        }
      end

      context 'with pam true' do
        let(:params) { { 'server' => 'test_server', 'pam' => true } }

        it {
          is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").
            with_content(%r{^auth-user-pass$})
        }
      end

      context 'custom options' do
        let(:params) do
          {
            'server' => 'test_server',
            'custom_options' => { 'this' => 'that' }
          }
        end

        it {
          is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").
            with_content(%r{^this that$})
        }
      end

      context 'with all parameters' do
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

        it {
          is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").
            with_content(%r{^client$}).
            with_content(%r{^ca\s+keys/test_client/ca\.crt$}).
            with_content(%r{^cert\s+keys/test_client/test_client.crt$}).
            with_content(%r{^key\s+keys/test_client/test_client\.key$}).
            with_content(%r{^dev\s+tap$}).
            with_content(%r{^proto\s+udp$}).
            with_content(%r{^remote\s+somewhere\s+123$}).
            with_content(%r{^remote\s+galaxy\s+123$}).
            with_content(%r{^compress lz4$}).
            with_content(%r{^resolv-retry\s+2m$}).
            with_content(%r{^verb\s+1$}).
            with_content(%r{^mute\s+10$}).
            with_content(%r{^auth-retry\s+interact$}).
            with_content(%r{^setenv\s+CLIENT_CERT\s+0$}).
            with_content(%r{^setenv_safe\s+FORWARD_COMPATIBLE\s+1$}).
            with_content(%r{^cipher\s+AES-256-GCM$}).
            with_content(%r{^tls-cipher\s+TLS-DHE-RSA-WITH-AES-256-CBC-SHA$}).
            with_content(%r{^tls-client$}).
            with_content(%r{^verify-x509-name\s+"test_server"\s+name$}).
            with_content(%r{^sndbuf\s+393216$}).
            with_content(%r{^rcvbuf\s+393215$}).
            with_content(%r{^pull$})
        }

        it { is_expected.not_to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").with_content(%r{^remote-cert-tls\s+server$}) }

        it { is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/README").with_content(%r{^readme text$}) }
      end

      context 'with extca' do
        let(:pre_condition) do
          'openvpn::server { "text_server_extca":
              tls_auth                => true,
              extca_enabled           => true,
              extca_ca_cert_file      => "/etc/ipa/ca.crt",
              extca_ca_crl_file       => "/etc/ipa/ca_crl.pem",
              extca_server_cert_file  => "/etc/pki/tls/certs/localhost.crt",
              extca_server_key_file   => "/etc/pki/tls/private/localhost.key",
              extca_dh_file           => "/etc/ipa/dh.pem",
              extca_tls_auth_key_file => "/etc/openvpn/keys/ta.key",
            }'
        end
        let(:params) { { 'server' => 'text_server_extca' } }

        it { is_expected.to compile.and_raise_error(%r{extca_enabled}) }
      end

      context 'with shared_ca' do
        let(:pre_condition) do
          'openvpn::server { "test_server":
            country       => "CO",
            province      => "ST",
            city          => "Some City",
            organization  => "example.org",
            email         => "testemail@example.org"
          }
          openvpn::server { "my_shared_ca":
            country       => "CO",
            province      => "ST",
            city          => "Some City",
            organization  => "example.org",
            email         => "testemail@example.org"
          }'
        end
        let(:params) do
          {
            'server' => 'test_server',
            'shared_ca' => 'my_shared_ca'
          }
        end

        it { is_expected.to contain_openvpn__ca('my_shared_ca') }
        it { is_expected.to contain_exec('generate certificate for test_client in context of my_shared_ca') }

        it {
          is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/test_client.conf").
            with_content(%r{^client$}).
            with_content(%r{^ca\s+keys/test_client/ca\.crt$}).
            with_content(%r{^cert\s+keys/test_client/test_client\.crt$}).
            with_content(%r{^key\s+keys/test_client/test_client\.key$})
        }

        it {
          is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/keys/test_client/test_client.crt").with(
            'ensure' => 'link',
            'target' => "#{server_directory}/my_shared_ca/easy-rsa/keys/issued/test_client.crt"
          )
        }

        it {
          is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/keys/test_client/test_client.key").with(
            'ensure' => 'link',
            'target' => "#{server_directory}/my_shared_ca/easy-rsa/keys/private/test_client.key"
          )
        }

        it {
          is_expected.to contain_file("#{server_directory}/test_server/download-configs/test_client/keys/test_client/ca.crt").with(
            'ensure' => 'link',
            'target' => "#{server_directory}/my_shared_ca/easy-rsa/keys/ca.crt"
          )
        }
      end

      context 'with not existed shared_ca' do
        let(:params) do
          {
            'server' => 'test_server',
            'shared_ca' => 'my_shared_ca'
          }
        end

        it { is_expected.to compile.and_raise_error(%r{Could not find resource}) }
      end
    end
  end
end
