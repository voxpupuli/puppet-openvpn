require 'spec_helper'

describe 'openvpn::deploy::client', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:title) { 'test_client' }

      context 'with manage_etc false' do
        let(:params) do
          {
            server: 'test_server',
            manage_etc: false
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/etc/openvpn/keys/test_client') }
        it { is_expected.to contain_package('openvpn') }
        it {
          is_expected.to contain_service('openvpn').with(
            ensure: 'running',
            enable: true
          )
        }
      end

      context 'with manage_etc true' do
        let(:params) do
          {
            server: 'test_server',
            manage_etc: true
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/etc/openvpn') }
        it { is_expected.to contain_file('/etc/openvpn/keys') }
        it { is_expected.to contain_file('/etc/openvpn/keys/test_client') }
      end
    end
  end
end
