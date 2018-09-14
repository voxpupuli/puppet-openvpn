require 'spec_helper'

describe 'openvpn::install', type: :class do
  let :default_facts do
    {
      os: { 'family' => 'Debian' },
      os: { 'name' => 'Ubuntu' },
    }
  end


  it { is_expected.to create_class('openvpn::install') }
  it { is_expected.to contain_package('openvpn') }

  it { is_expected.to contain_file('/etc/openvpn').with('ensure' => 'directory') }
  it { is_expected.to contain_file('/etc/openvpn/keys').with('ensure' => 'directory') }
  it { is_expected.to contain_file('/var/log/openvpn').with('ensure' => 'directory') }

  describe 'installed packages' do
    context 'debian' do

      context 'jessie' do
        let(:facts) do
          default_facts.merge(
            os: { 'release' => {'major' => '8' } },
          )
        end

        it { is_expected.to contain_package('openvpn-auth-ldap') }
        it { is_expected.to contain_package('easy-rsa') }
      end

      context 'stretch' do
        let(:facts) do
          default_facts.merge(
            os: { 'release' => {'major' => '9' } },
          )
        end

        it { is_expected.to contain_package('openvpn-auth-ldap') }
        it { is_expected.to contain_package('easy-rsa') }
      end
    end

    context 'redhat/centos' do
        let(:facts) do
          os: { 'family' => 'RedHat' },
          os: { 'name' => 'CentOS' },
          os: { 'release' => {'major' => '7' } },
        end

      it { is_expected.not_to contain_package('openvpn-auth-ldap') }
      it { is_expected.to contain_package('easy-rsa') }
    end

    context 'Archlinux' do
        let(:facts) do
          os: { 'family' => 'Archlinux' },
        end

      it { is_expected.not_to contain_package('openvpn-auth-ldap') }
      it { is_expected.to contain_package('easy-rsa') }
    end
  end
end
