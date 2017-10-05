require 'spec_helper'

describe 'openvpn::config', type: :class do
  context 'on Debian based machines' do
    let(:facts) do
      {
        osfamily: 'Debian',
        operatingsystem: 'Debian',
        operatingsystemrelease: '7',
        concat_basedir: '/var/lib/puppet/concat'
      }
    end

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
