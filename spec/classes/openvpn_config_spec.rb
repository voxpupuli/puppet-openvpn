# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn::config', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }

      case facts[:os]['family']
      when 'Debian'
        context 'on Debian based machines' do
          it { is_expected.to contain_concat('/etc/default/openvpn') }
          it { is_expected.to contain_concat__fragment('openvpn.default.header') }

          context 'enabled autostart_all' do
            let(:pre_condition) { 'class { "openvpn": autostart_all => true }' }

            it {
              is_expected.to contain_concat__fragment('openvpn.default.header').with(
                'content' => %r{^AUTOSTART="all"}
              )
            }
          end

          context 'disabled autostart_all' do
            let(:pre_condition) { 'class { "openvpn": autostart_all => false }' }

            it {
              is_expected.to contain_concat__fragment('openvpn.default.header').with(
                'content' => %r{^AUTOSTART=""}
              )
            }
          end
        end
      end
    end
  end
end
