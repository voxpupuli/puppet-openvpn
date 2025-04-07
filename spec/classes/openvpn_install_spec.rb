# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn::install', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:pre_condition) do
        'include openvpn'
      end
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to create_class('openvpn::install') }
      it { is_expected.to contain_package('openvpn') }

      it { is_expected.to contain_file('/etc/openvpn').with('ensure' => 'directory') }
      it { is_expected.to contain_file('/etc/openvpn/keys').with('ensure' => 'directory') }
      it { is_expected.to contain_file('/var/log/openvpn').with('ensure' => 'directory') }

      it { is_expected.to contain_package('easy-rsa') }

      case facts[:os]['family']
      when 'Debian'
        context 'debian' do
          it { is_expected.to contain_package('openvpn-auth-ldap') }
        end
      when 'Archlinux'
        context 'Archlinux' do
          it { is_expected.not_to contain_package('openvpn-auth-ldap') }
        end
      end
    end
  end
end
