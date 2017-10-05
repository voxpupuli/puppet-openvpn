require 'spec_helper'

describe 'openvpn', type: :class do
  context 'non-systemd systems' do
    let(:facts) do
      {
        concat_basedir: '/var/lib/puppet/concat',
        osfamily: 'Debian',
        operatingsystem: 'Ubuntu',
        operatingsystemrelease: '12.04'
      }
    end

    it { is_expected.to create_class('openvpn') }
    it { is_expected.to contain_class('openvpn::service') }
  end

  context 'systemd systems' do
    let(:facts) do
      {
        concat_basedir: '/var/lib/puppet/concat',
        osfamily: 'RedHat',
        operatingsystem: 'CentOS',
        operatingsystemrelease: '7.0'
      }
    end

    it { is_expected.to create_class('openvpn') }
    it { is_expected.not_to contain_class('openvpn::service') }
  end
end
