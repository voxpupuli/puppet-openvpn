# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn::install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          easyrsa: '3.0'
        )
      end
      let(:pre_condition) { 'include openvpn' }

      etc_directory = case os_facts[:os]['family']
                      when 'Solaris'
                        '/opt/local/etc'
                      when 'FreeBSD'
                        '/usr/local/etc'
                      else
                        '/etc'
                      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to create_class('openvpn::install') }

      it { is_expected.to contain_package('openvpn') }

      it { is_expected.to contain_file("#{etc_directory}/openvpn").with_ensure('directory') }

      it { is_expected.to contain_file("#{etc_directory}/openvpn/keys").with_ensure('directory') }

      it { is_expected.to contain_file('/var/log/openvpn').with_ensure('directory') }

      it { is_expected.to contain_package('easy-rsa') }

      if os_facts[:os]['family'] == 'Debian'
        it { is_expected.to contain_package('openvpn-auth-ldap') }
      else
        it { is_expected.not_to contain_package('openvpn-auth-ldap') }
      end
    end
  end
end
