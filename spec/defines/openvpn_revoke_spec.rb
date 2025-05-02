# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn::revoke' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          easyrsa: '3.0'
        )
      end

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
        let(:pre_condition) do
          [
            'openvpn::server { "test_server":
            country       => "CO",
            province      => "ST",
            city          => "Some City",
            organization  => "example.org",
            email         => "testemail@example.org"
          }',
            'openvpn::client { "test_client":
            server => "test_server"
          }'
          ].join
        end
        let(:title) { 'test_client' }
        let(:params) { { 'server' => 'test_server' } }

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/revoked/test_client").
            with_ensure('file')
        }

        it {
          is_expected.to contain_exec('revoke certificate for test_client in context of test_server').
            with_command("./easyrsa --batch revoke test_client; echo \"exit $?\" | grep -qE '(error 23|exit (0|2))'")
        }

        it {
          is_expected.to contain_exec('renew crl.pem on test_server because of revocation of test_client').
            with_command('./easyrsa --batch gen-crl')
        }

        it {
          is_expected.to contain_exec('copy renewed crl.pem to test_server keys directory because of revocation of test_client').
            with_command("cp #{server_directory}/test_server/easy-rsa/keys/crl.pem #{server_directory}/test_server/crl.pem")
        }
      end
    end
  end
end
