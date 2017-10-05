require 'spec_helper'

describe 'openvpn::service', type: :class do
  let(:pre_condition) { 'class { "openvpn": manage_service => true }' }
  let(:facts) do
    {
      osfamily: 'Debian',
      operatingsystem: 'Debian',
      concat_basedir: '/var/lib/puppet/concat',
      operatingsystemrelease: '7.0'
    }
  end

  it { is_expected.to create_class('openvpn::service') }
  it {
    is_expected.to contain_service('openvpn').with(
      'ensure'  => 'running',
      'enable'  => true
    )
  }
end
