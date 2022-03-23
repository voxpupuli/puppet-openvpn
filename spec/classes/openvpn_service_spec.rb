# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn::service', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:pre_condition) { 'class { "openvpn": manage_service => true }' }
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to create_class('openvpn::service') }

      it {
        is_expected.to contain_service('openvpn').with(
          'ensure' => 'running',
          'enable' => true
        )
      }
    end
  end
end
