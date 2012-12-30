require 'spec_helper'
 
describe 'openvpn', :type => :class do

  let (:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }

  it { should create_class('openvpn') }
  it { should contain_class('concat::setup') }
  it { should contain_package('openvpn') }
  it { should contain_service('openvpn').with(
    'ensure'  => 'running',
    'enable'  => true
  ) }

  it { should contain_file('/etc/openvpn').with('ensure' => 'directory') }
  it { should contain_file('/etc/openvpn/keys').with('ensure' => 'directory') }

  it { should contain_concat__fragment('openvpn.default.header') }

end
