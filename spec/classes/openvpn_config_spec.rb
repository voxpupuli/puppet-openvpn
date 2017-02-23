require 'spec_helper'

describe 'openvpn::config' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { should create_class('openvpn::config') }

      if facts[:osfamily] == 'Debian'
        it { should contain_concat('/etc/default/openvpn') }
        it { should contain_concat__fragment('openvpn.default.header') }
      end
#  context "on Debian based machines" do
#    let (:facts) { {
#      osfamily: 'Debian',
#      operatingsystem: 'Debian',
#      operatingsystemrelease: '7',
#      concat_basedir: '/var/lib/puppet/concat'
#    } }


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
end
