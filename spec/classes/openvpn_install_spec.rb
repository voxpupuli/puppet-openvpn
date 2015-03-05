require 'spec_helper'

describe 'openvpn::install', :type => :class do
  let(:osfamily) { 'Debian' }
  let(:operatingsystemmajrelease) { nil }
  let(:operatingsystemrelease) { nil }
  let(:operatingsystem) { 'Ubuntu' }
  let(:operatingsystemrelease) { '13.10' }
  let(:facts) do
    {
      :osfamily => osfamily,
      :operatingsystemmajrelease => operatingsystemmajrelease,
      :operatingsystemrelease => operatingsystemrelease,
      :operatingsystem => operatingsystem,
      :operatingsystemrelease => operatingsystemrelease,
    }
  end

  it { should create_class('openvpn::install') }
  it { should contain_package('openvpn') }

  it { should contain_file('/etc/openvpn').with('ensure' => 'directory') }
  it { should contain_file('/etc/openvpn/keys').with('ensure' => 'directory') }
  it { should contain_file('/var/log/openvpn').with('ensure' => 'directory') }

  describe 'installed packages' do
    context 'debian' do
      let(:osfamily) { 'Debian' }
      let(:operatingsystem) { 'Debian' }

      context 'squeeze' do
        let(:operatingsystemrelease) { '6.5' }
        it { should_not contain_package('openvpn-auth-ldap') }
        it { should_not contain_package('easy-rsa') }
      end

      context 'wheezy' do
        let(:operatingsystemrelease) { '7.4' }
        it { should contain_package('openvpn-auth-ldap') }
        it { should_not contain_package('easy-rsa') }
      end

      context 'jessie' do
        let(:operatingsystemrelease) { '8.0.0' }
        it { should contain_package('openvpn-auth-ldap') }
        it { should contain_package('easy-rsa') }
      end
    end

    context 'redhat/centos' do
      let(:osfamily) { 'RedHat' }

      context '5' do
        let(:operatingsystemrelease) { '5' }
        it { should_not contain_package('openvpn-auth-ldap') }
        it { should_not contain_package('easy-rsa') }
      end

      context '6.3' do
        let(:operatingsystemrelease) { '6.3' }
        it { should_not contain_package('openvpn-auth-ldap') }
        it { should_not contain_package('easy-rsa') }
      end

      context '6.4' do
        let(:operatingsystemrelease) { '6.4' }
        it { should_not contain_package('openvpn-auth-ldap') }
        it { should contain_package('easy-rsa') }
      end

      context '7' do
        let(:operatingsystemrelease) { '7' }
        it { should_not contain_package('openvpn-auth-ldap') }
        it { should contain_package('easy-rsa') }
      end
    end

    context 'Amazon' do
      let(:osfamily) { 'Linux' }
      let(:operatingsystem) { 'Amazon' }
      let(:operatingsystemrelease) { nil }

      it { should_not contain_package('openvpn-auth-ldap') }
      it { should contain_package('easy-rsa') }
    end
  end
end
