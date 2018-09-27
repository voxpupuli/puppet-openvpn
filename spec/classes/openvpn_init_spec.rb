require 'spec_helper'

describe 'openvpn', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:pre_condition) { 'class { "openvpn" : manage_service => true }' }
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }

      os_name = facts[:os]['name']
      os_release = facts[:os]['release']['major']
      case "#{os_name}-#{os_release}"
      when 'Ubuntu-14.04', 'CentOS-6', 'RedHat-6', %r{FreeBSD}
        context 'system without systemd' do
          it { is_expected.to create_class('openvpn') }
          it { is_expected.to contain_class('openvpn::service') }
        end
      when 'Ubuntu-16.04', 'CentOS-7', 'RedHat-7', 'Debian-8', 'Debian-9', %r{Archlinux}
        context 'system with systemd' do
          it { is_expected.to create_class('openvpn') }
          it { is_expected.not_to contain_class('openvpn::service') }
        end
      else
        context 'unsupported systems' do
          it { is_expected.to raise_error(%r{unsupported OS}) }
        end
      end
    end
  end
end
