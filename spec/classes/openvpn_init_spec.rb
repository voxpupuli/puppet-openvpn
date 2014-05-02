require 'spec_helper'

describe 'openvpn', :type => :class do

  let(:facts) { {
    :concat_basedir => '/var/lib/puppet/concat',
    :osfamily       => 'Debian',
    :lsbdistid      => 'Ubuntu',
    :lsbdistrelease => '12.04',
  } }

  it { should create_class('openvpn') }

end
