require 'spec_helper'
 
describe 'openvpn::install', :type => :class do

  it { should create_class('openvpn::install') }
  it { should contain_package('openvpn') }

  it { should contain_file('/etc/openvpn').with('ensure' => 'directory') }
  it { should contain_file('/etc/openvpn/keys').with('ensure' => 'directory') }

end
