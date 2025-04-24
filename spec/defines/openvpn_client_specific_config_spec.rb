# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn::client_specific_config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          easyrsa: '3.0'
        )
      end
      let(:pre_condition) do
        'openvpn::server { "test_server":
          country       => "CO",
          province      => "ST",
          city          => "Some City",
          organization  => "example.org",
          email         => "testemail@example.org"
        }
        openvpn::client { "test_client":
          server => "test_server"
        }'
      end

      let(:title) { 'test_client' }

      server_directory = case os_facts[:os]['family']
                         when 'Archlinux', 'Debian', 'RedHat'
                           '/etc/openvpn/server'
                         when 'Solaris'
                           '/opt/local/etc/openvpn'
                         when 'FreeBSD'
                           '/usr/local/etc/openvpn'
                         else
                           '/etc/openvpn'
                         end

      context 'with the minimum parameters' do
        let(:params) { { server: 'test_server' } }

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file("#{server_directory}/test_server/client-configs/test_client")
        }
      end

      context 'with all parameters' do
        let(:params) do
          {
            server: 'test_server',
            iroute: ['10.0.1.0 255.255.255.0'],
            iroute_ipv6: ['2001:db8:1234::/64'],
            ifconfig: '10.10.10.2 255.255.255.0',
            ifconfig_ipv6: '2001:db8:0:123::2/64 2001:db8:0:123::1',
            route: ['10.200.100.0 255.255.255.0 10.10.10.1'],
            dhcp_options: ['DNS 8.8.8.8'],
            custom_options: { 'this' => 'that' },
            redirect_gateway: true
          }
        end

        it { is_expected.to compile.with_all_deps }

        it {
          is_expected.to contain_file("#{server_directory}/test_server/client-configs/test_client").
            with_content(%r{iroute 10.0.1.0 255.255.255.0}).
            with_content(%r{iroute-ipv6 2001:db8:1234::/64}).
            with_content(%r{ifconfig-push 10.10.10.2 255.255.255.0}).
            with_content(%r{ifconfig-ipv6-push 2001:db8:0:123::2/64 2001:db8:0:123::1}).
            with_content(%r{route 10.200.100.0 255.255.255.0 10.10.10.1}).
            with_content(%r{dhcp-option DNS 8.8.8.8}).
            with_content(%r{this that}).
            with_content(%r{redirect-gateway})
        }
      end
    end
  end
end
