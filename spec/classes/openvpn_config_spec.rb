# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          easyrsa: '3.0'
        )
      end

      let(:pre_condition) { 'include openvpn' } if os_facts[:os]['family'] == 'Debian'

      it { is_expected.to compile.with_all_deps }

      case os_facts[:os]['family']
      when 'Debian'
        it { is_expected.to contain_concat('/etc/default/openvpn') }

        it { is_expected.to contain_concat__fragment('openvpn.default.header') }

        context 'enabled autostart_all' do
          let(:pre_condition) { 'class { "openvpn": autostart_all => true }' }

          it { is_expected.to contain_concat__fragment('openvpn.default.header').with_content(%r{^AUTOSTART="all"}) }
        end

        context 'disabled autostart_all' do
          let(:pre_condition) { 'class { "openvpn": autostart_all => false }' }

          it { is_expected.to contain_concat__fragment('openvpn.default.header').with_content(%r{^AUTOSTART=""}) }
        end
      end
    end
  end
end
