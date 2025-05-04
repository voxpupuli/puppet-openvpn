# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          easyrsa: '3.0'
        )
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to create_class('openvpn') }
      it { is_expected.to contain_class('openvpn::install') }
      it { is_expected.to contain_class('openvpn::config') }

      if os_facts[:service_provider] == 'systemd'
        context 'system with systemd' do
          it { is_expected.to create_class('openvpn') }
          it { is_expected.not_to contain_class('openvpn::service') }
        end
      else
        context 'system without systemd' do
          it { is_expected.to create_class('openvpn') }
          it { is_expected.to contain_class('openvpn::service') }
        end
      end
    end
  end
end
