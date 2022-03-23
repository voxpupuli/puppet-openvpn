# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:pre_condition) { 'class { "openvpn" : manage_service => true }' }
      let(:facts) do
        facts
      end
      let(:title) { 'test openvpn hiera lookups' }

      it { is_expected.to create_class('openvpn') }

      it do
        is_expected.to contain_openvpn__server('winterthur').with(
          'country' => 'CH',
          'province' => 'ZH',
          'city' => 'Winterthur',
          'organization' => 'example.org',
          'email' => 'root@example.org',
          'server' => '10.200.200.0 255.255.255.0'
        )
      end

      it do
        is_expected.to contain_openvpn__server('uster').with(
          'country' => 'CH',
          'province' => 'ZH',
          'city' => 'Uster',
          'organization' => 'example.com',
          'email' => 'root@example.com',
          'server' => '10.100.100.0 255.255.255.0'
        )
      end

      it do
        is_expected.to contain_openvpn__client('winti-client1').with(
          'server' => 'winterthur'
        )
      end

      it do
        is_expected.to contain_openvpn__client('winti-client2').with(
          'server' => 'winterthur'
        )
      end

      it do
        is_expected.to contain_openvpn__client('uster-client1').with(
          'server' => 'uster'
        )
      end

      it do
        is_expected.to contain_openvpn__client('uster-client2').with(
          'server' => 'uster'
        )
      end

      it do
        is_expected.to contain_openvpn__client_specific_config('winti-client1').with(
          'server' => 'winterthur',
          'ifconfig' => '10.200.200.50 10.200.200.51'
        )
      end

      it do
        is_expected.to contain_openvpn__client_specific_config('uster-client1').with(
          'server' => 'uster',
          'ifconfig' => '10.100.100.50 10.100.100.51'
        )
      end

      it do
        is_expected.to contain_openvpn__revoke('winti-client2').with(
          'server' => 'winterthur'
        )
      end

      it do
        is_expected.to contain_openvpn__revoke('uster-client2').with(
          'server' => 'uster'
        )
      end
    end
  end
end
