require 'spec_helper'

describe 'openvpn', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:pre_condition) { 'class { "openvpn" : manage_service => true }' }

      it { is_expected.to compile.with_all_deps }

      os_name = facts[:os]['name']
      os_release = facts[:os]['release']['major']
      case "#{os_name}-#{os_release}"
      when 'Ubuntu-14.04', 'CentOS-6', 'RedHat-6', %r{FreeBSD}
        let(:facts) do
          facts
        end

        context 'system without systemd' do
          it { is_expected.to create_class('openvpn') }
          it { is_expected.to contain_class('openvpn::service') }
        end
      when 'Ubuntu-18.04', 'Ubuntu-16.04', 'CentOS-7', 'RedHat-7', 'CentOS-8', 'RedHat-8', 'Debian-8', 'Debian-9', %r{Archlinux}
        let(:facts) do
          facts.merge(
            service_provider: 'systemd'
          )
        end

        context 'system with systemd' do
          it { is_expected.to create_class('openvpn') }
          it { is_expected.not_to contain_class('openvpn::service') }
        end
      end
    end
  end
end
