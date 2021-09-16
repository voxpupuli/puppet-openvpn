require 'spec_helper'

describe 'openvpn::deploy::export', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
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

      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with("#{server_directory}/test_server/download-configs/test_client/test_client.conf").and_return(true)
        allow(File).to receive(:exist?).with("#{server_directory}/test_server/download-configs/test_client/keys/test_client/ca.crt").and_return(true)
        allow(File).to receive(:exist?).with("#{server_directory}/test_server/download-configs/test_client/keys/test_client/test_client.crt").and_return(true)
        allow(File).to receive(:exist?).with("#{server_directory}/test_server/download-configs/test_client/keys/test_client/test_client.key").and_return(true)
        allow(File).to receive(:exist?).with("#{server_directory}/test_server/download-configs/test_client/keys/test_client/ta.key").and_return(true)

        allow(File).to receive(:read).and_call_original
        allow(File).to receive(:read).with("#{server_directory}/test_server/download-configs/test_client/test_client.conf").and_return('config')
        allow(File).to receive(:read).with("#{server_directory}/test_server/download-configs/test_client/keys/test_client/ca.crt").and_return('ca')
        allow(File).to receive(:read).with("#{server_directory}/test_server/download-configs/test_client/keys/test_client/test_client.crt").and_return('crt')
        allow(File).to receive(:read).with("#{server_directory}/test_server/download-configs/test_client/keys/test_client/test_client.key").and_return('key')
        allow(File).to receive(:read).with("#{server_directory}/test_server/download-configs/test_client/keys/test_client/ta.key").and_return('ta')
      end

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
