require 'spec_helper'

describe 'openvpn::install', type: :class do
  let(:osfamily) { 'Debian' }
  let(:operatingsystemmajrelease) { nil }
  let(:operatingsystem) { 'Ubuntu' }
  let(:operatingsystemrelease) { '13.10' }
  let(:facts) do
    {
      osfamily: osfamily,
      operatingsystemmajrelease: operatingsystemmajrelease,
      operatingsystemrelease: operatingsystemrelease,
      operatingsystem: operatingsystem
    }
  end

  it { is_expected.to create_class('openvpn::install') }
  it { is_expected.to contain_package('openvpn') }

  it { is_expected.to contain_file('/etc/openvpn').with('ensure' => 'directory') }
  it { is_expected.to contain_file('/etc/openvpn/keys').with('ensure' => 'directory') }
  it { is_expected.to contain_file('/var/log/openvpn').with('ensure' => 'directory') }

  describe 'installed packages' do
    context 'debian' do
      let(:osfamily) { 'Debian' }
      let(:operatingsystem) { 'Debian' }

      context 'squeeze' do
        let(:operatingsystemrelease) { '6.5' }

        it { is_expected.not_to contain_package('openvpn-auth-ldap') }
        it { is_expected.not_to contain_package('easy-rsa') }
      end

      context 'wheezy' do
        let(:operatingsystemrelease) { '7.4' }

        it { is_expected.to contain_package('openvpn-auth-ldap') }
        it { is_expected.not_to contain_package('easy-rsa') }
      end

      context 'jessie' do
        let(:operatingsystemrelease) { '8.0' }

        it { is_expected.to contain_package('openvpn-auth-ldap') }
        it { is_expected.to contain_package('easy-rsa') }
      end

      context 'stretch' do
        let(:operatingsystemrelease) { '9.0' }

        it { is_expected.to contain_package('openvpn-auth-ldap') }
        it { is_expected.to contain_package('easy-rsa') }
      end
    end

    context 'redhat/centos' do
      let(:osfamily) { 'RedHat' }

      it { is_expected.not_to contain_package('openvpn-auth-ldap') }
      it { is_expected.to contain_package('easy-rsa') }
    end

    context 'Amazon' do
      let(:osfamily) { 'Linux' }
      let(:operatingsystem) { 'Amazon' }
      let(:operatingsystemrelease) { nil }

      it { is_expected.not_to contain_package('openvpn-auth-ldap') }
      it { is_expected.to contain_package('easy-rsa') }
    end

    context 'Archlinux' do
      let(:osfamily) { 'Archlinux' }

      it { is_expected.not_to contain_package('openvpn-auth-ldap') }
      it { is_expected.to contain_package('easy-rsa') }
    end
  end
end
