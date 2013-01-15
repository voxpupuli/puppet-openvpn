require 'spec_helper'
 
describe 'openvpn::config', :type => :class do
  
  it { should create_class('openvpn::config') }
  
  context "on Debian based machines" do
    let (:facts) { { :osfamily => 'Debian', :concat_basedir => '/var/lib/puppet/concat' } }

    it { should contain_class('concat::setup') }
    it { should contain_concat('/etc/default/openvpn') }
    it { should contain_concat__fragment('openvpn.default.header') }
  end

end
