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

      it {
        is_expected.to contain_exec('revoke certificate for test_client in context of test_server').with(
          'command' => ". ./vars && ./revoke-full test_client; echo \"exit $?\" | grep -qE '(error 23|exit (0|2))' && touch revoked/test_client"
        )
      }
    end
  end
end
