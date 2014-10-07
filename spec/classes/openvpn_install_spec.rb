require 'spec_helper'

describe 'openvpn::install', :type => :class do
  let(:osfamily) { 'Debian' }
  let(:operatingsystemmajrelease) { nil }
  let(:lsbdistid) { 'Ubuntu' }
  let(:lsbdistrelease) { '13.10' }
  let(:facts) do
    {
      :osfamily => osfamily,
      :operatingsystemmajrelease => operatingsystemmajrelease,
      :lsbdistid => lsbdistid,
      :lsbdistrelease => lsbdistrelease,
    }
  end

  it { should create_class('openvpn::install') }
  it { should contain_package('openvpn') }

  it { should contain_file('/etc/openvpn').with('ensure' => 'directory') }
  it { should contain_file('/etc/openvpn/keys').with('ensure' => 'directory') }

  describe 'installed packages' do
    context 'debian' do
      let(:osfamily) { 'Debian' }
      let(:lsbdistid) { 'Debian' }

      context 'squeeze' do
        let(:lsbdistrelease) { '6.5' }
        it { should_not contain_package('openvpn-auth-ldap') }
        it { should_not contain_package('easy-rsa') }
      end

      context 'wheezy' do
        let(:lsbdistrelease) { '7.4' }
        it { should contain_package('openvpn-auth-ldap') }
        it { should_not contain_package('easy-rsa') }
      end

      context 'jessie' do
        let(:lsbdistrelease) { '8.0.0' }
        it { should contain_package('openvpn-auth-ldap') }
        it { should contain_package('easy-rsa') }
      end
    end
  end
end
