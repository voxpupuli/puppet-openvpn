require 'spec_helper'

describe 'openvpn', type: :class do
  context 'non-systemd systems' do
    let(:facts) do
      {
        concat_basedir: '/var/lib/puppet/concat',
        os: { 'family' => 'Debian' },
        os: { 'name' => 'Ubuntu' },
        os: { 'release' => {'major' => '16.04' } },
      }
    end

    it { is_expected.to create_class('openvpn') }
    it { is_expected.to contain_class('openvpn::service') }
  end

  context 'systemd systems' do
    let(:facts) do
      {
        concat_basedir: '/var/lib/puppet/concat',
        os: { 'family' => 'RedHat' },
        os: { 'name' => 'CentOS' },
        os: { 'release' => {'major' => '7' } },
      }
    end

    it { is_expected.to create_class('openvpn') }
    it { is_expected.not_to contain_class('openvpn::service') }
  end
end
