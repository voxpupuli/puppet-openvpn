require 'spec_helper'

describe 'openvpn::revoke', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
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
      let(:facts) do
        facts
      end
      let(:title) { 'test_client' }
      let(:params) { { 'server' => 'test_server' } }

      it { is_expected.to compile.with_all_deps }
      context 'easyrsa version 2.0' do
        let(:facts) do
          super().merge('easyrsa' => '2.0')
        end

        it {
          is_expected.to contain_exec('revoke certificate for test_client in context of test_server').with(
            'command' => ". ./vars && ./revoke-full test_client; echo \"exit $?\" | grep -qE '(error 23|exit (0|2))' && touch revoked/test_client"
          )
        }
      end
      context 'easyrsa version 3.0' do
        let(:facts) do
          super().merge('easyrsa' => '3.0')
        end

        it {
          is_expected.to contain_exec('revoke certificate for test_client in context of test_server').with(
            'command' => ". ./vars && ./easyrsa --batch revoke test_client; echo \"exit $?\" | grep -qE '(error 23|exit (0|2|))' && touch revoked/test_client"
          )
        }
        it {
          is_expected.to contain_exec('renew crl.pem for test_client').with(
            'command' => ". ./vars && EASYRSA_REQ_CN='' EASYRSA_REQ_OU='' openssl ca -gencrl -out ../crl.pem -config ./openssl.cnf"
          )
        }
      end
    end
  end
end
