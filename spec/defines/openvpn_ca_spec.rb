# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn::ca' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge(
          easyrsa: '3.0'
        )
      end
      let(:title) { 'test_server' }

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

      context 'with default parameters' do
        let(:params) do
          {
            'country' => 'CO',
            'province' => 'ST',
            'city' => 'Some City',
            'organization' => 'example.org',
            'email' => 'admin@example.org'
          }
        end

        it { is_expected.to contain_class('openvpn') }

        it { is_expected.to contain_file("#{server_directory}/test_server").with_ensure('directory') }

        it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa").with_ensure('directory') }

        it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/revoked").with_ensure('directory') }

        it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/easyrsa").with_ensure('link') } if os_facts[:os]['family'] == 'Archlinux'

        it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_mode('0550') }

        it {
          is_expected.to contain_file("#{server_directory}/test_server/keys").
            with(ensure: 'link', target: "#{server_directory}/test_server/easy-rsa/keys")
        }

        it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/openssl.cnf") }

        it { is_expected.to contain_file("#{server_directory}/test_server/crl.pem").with_mode('0640') }

        it { is_expected.to contain_file("#{server_directory}/test_server/crl.pem").with_group('nobody') } if os_facts[:os]['family'] == %r{'RedHat'|'Solaris'|'FreeBSD'}

        it { is_expected.to contain_file("#{server_directory}/test_server/crl.pem").with_group('nogroup') } if os_facts[:os]['family'] == 'Debian'

        it { is_expected.to contain_file("#{server_directory}/test_server/crl.pem").with_group('network') } if os_facts[:os]['family'] == 'Archlinux'

        it { is_expected.to contain_exec('initca test_server').with_command("./easyrsa --batch --pki-dir=#{server_directory}/test_server/easy-rsa/keys init-pki && ./easyrsa --batch build-ca nopass") }

        it { is_expected.to contain_exec('generate dh param test_server').with_command('./easyrsa --batch gen-dh') }
        it { is_expected.to contain_exec('generate server cert test_server').with_command("./easyrsa build-server-full 'server' nopass") }
        it { is_expected.to contain_exec('create crl.pem on test_server').with_command('./easyrsa gen-crl') }
        it { is_expected.to contain_exec('copy created crl.pem to test_server keys directory').with_command("cp #{server_directory}/test_server/easy-rsa/keys/crl.pem #{server_directory}/test_server/crl.pem") }

        it {
          is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").
            with_content(%r{set_var EASYRSA_REQ_COUNTRY "CO"$}).
            with_content(%r{set_var EASYRSA_REQ_PROVINCE "ST"$}).
            with_content(%r{set_var EASYRSA_REQ_CITY "Some City"$}).
            with_content(%r{set_var EASYRSA_REQ_ORG "example.org"$}).
            with_content(%r{set_var EASYRSA_REQ_EMAIL "admin@example.org"$})
        }
      end

      context 'with all parameters' do
        let(:params) do
          {
            'dn_mode' => 'cn_only',
            'country' => 'CO',
            'province' => 'ST',
            'city' => 'Some City',
            'organization' => 'example.org',
            'email' => 'testemail@example.org',
            'group' => 'someone',
            'ssl_key_size' => 2048,
            'common_name' => 'mylittlepony',
            'ca_expire' => 365,
            'digest' => 'sha256',
            'key_expire' => 365,
            'key_cn' => 'yolo',
            'key_name' => 'burp',
            'key_ou' => 'NSA'
          }
        end

        it {
          is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").
            with_content(%r{set_var EASYRSA_DN "cn_only"$}).
            with_content(%r{set_var EASYRSA_CA_EXPIRE 365$}).
            with_content(%r{set_var EASYRSA_CERT_EXPIRE 365$}).
            with_content(%r{set_var EASYRSA_REQ_CN "yolo"$}).
            with_content(%r{set_var EASYRSA_REQ_OU "NSA"$}).
            with_content(%r{set_var EASYRSA_DIGEST sha256$}).
            with_content(%r{set_var EASYRSA_KEY_SIZE 2048$})
        }
      end
    end
  end
end
