require 'spec_helper'

describe 'openvpn::deploy::export', type: :define do
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
        facts.merge(
          openvpn: { 'test_server' => { 'test_client' => { 'conf' => 'config', 'crt' => 'crt', 'ca' => 'ca', 'key' => 'key', 'ta' => 'ta' } } }
        )
      end
      let(:title) { 'test_client' }
      let(:params) { { 'server' => 'test_server' } }

      it { is_expected.to compile.with_all_deps }

      context 'exported resources' do
        subject { exported_resources }

        it { is_expected.to contain_file('exported-test_server-test_client-config').with_content('config') }
        it { is_expected.to contain_file('exported-test_server-test_client-ca').with_content('ca') }
        it { is_expected.to contain_file('exported-test_server-test_client-crt').with_content('crt') }
        it { is_expected.to contain_file('exported-test_server-test_client-key').with_content('key') }

        context 'with tls_auth' do
          let(:params) { { 'server' => 'test_server', 'tls_auth' => true } }

          it { is_expected.to contain_file('exported-test_server-test_client-ta').with_content('ta') }
        end
      end
    end
  end
end
