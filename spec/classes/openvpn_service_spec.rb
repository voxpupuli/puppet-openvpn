# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          easyrsa: '3.0'
        )
      end
      let(:pre_condition) { 'include openvpn' }

      it { is_expected.to compile.with_all_deps }

      context 'enabled manage_service and disabled namespecific_rclink' do
        let(:pre_condition) do
          'class { "openvpn":
            manage_service => true,
            namespecific_rclink => false
          }'
        end

        it { is_expected.to create_class('openvpn::service') }

        it { is_expected.to contain_service('openvpn').with_ensure('running').with_enable(true) }
      end

      context 'disabled manage_service and disabled namespecific_rclink' do
        let(:pre_condition) do
          'class { "openvpn":
            manage_service => false,
            namespecific_rclink => false
          }'
        end

        it { is_expected.to create_class('openvpn::service') }

        it { is_expected.not_to contain_service('openvpn') }
      end

      context 'disabled manage_service and enabled namespecific_rclink' do
        let(:pre_condition) do
          'class { "openvpn":
            manage_service => false,
            namespecific_rclink => true
          }'
        end

        it { is_expected.to create_class('openvpn::service') }

        it { is_expected.not_to contain_service('openvpn') }
      end
    end
  end
end
