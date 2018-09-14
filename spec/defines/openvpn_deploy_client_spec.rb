require 'spec_helper'

describe 'openvpn::deploy::client', type: :define do
  let(:title) { 'test_client' }
  let(:params) { { 'server' => 'test_server' } }
  let(:facts) do
    {
      fqdn: 'somehost',
      concat_basedir: '/var/lib/puppet/concat',
      os: { 'family' => 'Debian' },
      os: { 'name' => 'Ubuntu' },
      os: { 'release' => {'major' => '16.04' } },
    }
  end

  it { is_expected.to contain_file('/etc/openvpn/keys/test_client') }

  it { is_expected.to contain_package('openvpn') }
  it {
    is_expected.to contain_service('openvpn').with(
      ensure: 'running',
      enable: true
    )
  }

  context 'with manage_etc' do
    let(:params) { { 'server' => 'test_server', 'manage_etc' => true } }

    it { is_expected.to contain_file('/etc/openvpn') }
    it { is_expected.to contain_file('/etc/openvpn/keys') }
    it { is_expected.to contain_file('/etc/openvpn/keys/test_client') }
  end
end
