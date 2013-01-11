require 'spec_helper'
 
describe 'openvpn::service', :type => :class do

  let (:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }

  it { should create_class('openvpn::service') }
  it { should contain_service('openvpn').with(
    'ensure'  => 'running',
    'enable'  => true
  ) }

end
