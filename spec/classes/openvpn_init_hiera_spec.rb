require 'spec_helper'

describe 'openvpn', :type => :class do

  let(:title) { 'test openvpn hiera lookups' }

  let(:facts) do
    {
      :concat_basedir => '/var/lib/puppet/concat',
      :osfamily => 'Debian',
      :operatingsystem => 'Ubuntu',
      :operatingsystemrelease => '12.04',
    }
  end

  it { should create_class('openvpn') }
  it { should contain_class('openvpn::service') }

  it do should contain_openvpn__server('winterthur').with(
    'country'      => 'CH',
    'province'     => 'ZH',
    'city'         => 'Winterthur',
    'organization' => 'example.org',
    'email'        => 'root@example.org',
    'server'       => '10.200.200.0 255.255.255.0',
  ) end

  it do should contain_openvpn__server('uster').with(
    'country'      => 'CH',
    'province'     => 'ZH',
    'city'         => 'Uster',
    'organization' => 'example.com',
    'email'        => 'root@example.com',
    'server'       => '10.100.100.0 255.255.255.0',
  ) end

  it do should contain_openvpn__client('winti-client1').with(
    'server' => 'winterthur',
  ) end

  it do should contain_openvpn__client('winti-client1').with(
    'server' => 'winterthur',
  ) end

  it do should contain_openvpn__client('uster-client1').with(
    'server' => 'uster',
  ) end

  it do should contain_openvpn__client('uster-client2').with(
    'server' => 'uster',
  ) end

  it do should contain_openvpn__client_specific_config('winti-client1').with(
    'server'   => 'winterthur',
    'ifconfig' => '10.200.200.50 10.200.200.51',
  ) end

  it do should contain_openvpn__client_specific_config('uster-client1').with(
    'server'   => 'uster',
    'ifconfig' => '10.100.100.50 10.100.100.51',
  ) end

  it do should contain_openvpn__revoke('winti-client2').with(
    'server'   => 'winterthur',
  ) end

  it do should contain_openvpn__revoke('uster-client2').with(
    'server'   => 'uster',
  ) end

end
