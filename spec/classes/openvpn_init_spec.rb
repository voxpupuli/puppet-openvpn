require 'spec_helper'

describe 'openvpn', :type => :class do

  context 'non-systemd systems' do
    let(:facts) { {
      :concat_basedir => '/var/lib/puppet/concat',
      :osfamily => 'Debian',
      :operatingsystem => 'Ubuntu',
      :operatingsystemrelease => '12.04',
    } }

    it { should create_class('openvpn') }
    it { should contain_class('openvpn::service') }
  end

  context 'systemd systems' do
    let(:facts) { {
      :concat_basedir => '/var/lib/puppet/concat',
      :osfamily => 'RedHat',
      :operatingsystemrelease => '7.0',
    } }

    it { should create_class('openvpn') }
    it { should_not contain_class('openvpn::service') }
  end

end
