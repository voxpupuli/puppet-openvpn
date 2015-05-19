require 'spec_helper'
 
describe 'openvpn::service', :type => :class do

  let (:pre_condition) { 'class { "openvpn": manage_service => true }' }
  let (:facts) do
    { 
      :osfamily => 'Debian',
      :operatingsystem => 'Debian',
      :concat_basedir => '/var/lib/puppet/concat',
    }
  end

  it { should create_class('openvpn::service') }
  it { should contain_service('openvpn').with(
    'ensure'  => 'running',
    'enable'  => true
  ) }

end
