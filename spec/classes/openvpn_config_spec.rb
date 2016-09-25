require 'spec_helper'

describe 'openvpn::config', :type => :class do
  it { should create_class('openvpn::config') }

  context "on Debian based machines" do
    let (:facts) { {
      osfamily: 'Debian',
      operatingsystem: 'Debian',
      operatingsystemrelease: '7',
      concat_basedir: '/var/lib/puppet/concat'
    } }

    it { should contain_concat('/etc/default/openvpn') }
    it { should contain_concat__fragment('openvpn.default.header') }

    context "enabled autostart_all" do
      let(:pre_condition) { 'class { "openvpn": autostart_all => true }' }
      it { should contain_concat__fragment('openvpn.default.header').with(
        'content' => /^AUTOSTART="all"/
      )}
    end

    context "disabled autostart_all" do
      let(:pre_condition) { 'class { "openvpn": autostart_all => false }' }
      it { should contain_concat__fragment('openvpn.default.header').with(
        'content' => /^AUTOSTART=""/
      )}
    end
  end
end
