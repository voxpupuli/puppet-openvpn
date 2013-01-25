require 'spec_helper'
 
describe 'openvpn', :type => :class do

  let (:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }

  it { should create_class('openvpn') }

end
