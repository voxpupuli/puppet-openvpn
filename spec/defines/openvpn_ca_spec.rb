require 'spec_helper'

describe 'openvpn::ca', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      let(:title) { 'test_server' }

      case facts[:os]['family']
      when 'RedHat'
        server_directory = if facts[:os]['release']['major'] == '8'
                             '/etc/openvpn/server'
                           else
                             '/etc/openvpn'
                           end

        context 'creating a server with the minimum parameters' do
          let(:params) do
            {
              'country'      => 'CO',
              'province'     => 'ST',
              'city'         => 'Some City',
              'organization' => 'example.org',
              'email'        => 'testemail@example.org'
            }
          end

          it { is_expected.to contain_package('easy-rsa').with('ensure' => 'installed') }
          it {
            is_expected.to contain_file("#{server_directory}/test_server/crl.pem").with(
              'mode'    => '0640',
              'group'   => 'nobody'
            )
          }

          # Files associated with a server config

          it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with(mode: '0550') }
          it {
            is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/keys/crl.pem").
              with(ensure: 'link', target: "#{server_directory}/test_server/crl.pem")
          }
          it {
            is_expected.to contain_file("#{server_directory}/test_server/keys").
              with(ensure: 'link', target: "#{server_directory}/test_server/easy-rsa/keys")
          }

          # Execs to working with certificates

          it { is_expected.to contain_exec('generate dh param test_server').with_creates("#{server_directory}/test_server/easy-rsa/keys/dh.pem") }
          it { is_expected.to contain_exec('initca test_server') }
          it { is_expected.to contain_exec('generate server cert test_server') }
          it { is_expected.to contain_exec('create crl.pem on test_server') }
          it { is_expected.not_to contain_exec('update crl.pem on test_server') }

          it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export EASYRSA_CA_EXPIRE=3650$}) }
          it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export EASYRSA_CERT_EXPIRE=3650$}) }
          it { is_expected.not_to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{EASYRSA_REQ_CN}) }
          it { is_expected.not_to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{EASYRSA_REQ_OU}) }
        end

        context 'creating a ca setting all parameters' do
          let(:params) do
            {
              'country' => 'CO',
              'province'        => 'ST',
              'city'            => 'Some City',
              'organization'    => 'example.org',
              'email'           => 'testemail@example.org',
              'group'           => 'someone',
              'ssl_key_size'    => 2048,
              'common_name'     => 'mylittlepony',
              'ca_expire'       => 365,
              'key_expire'      => 365,
              'key_cn'          => 'yolo',
              'key_name'        => 'burp',
              'key_ou'          => 'NSA'
            }
          end

          it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export EASYRSA_CA_EXPIRE=365$}) }
          it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export EASYRSA_CERT_EXPIRE=365$}) }
          it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export EASYRSA_REQ_CN="yolo"$}) }
          it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export EASYRSA_REQ_OU="NSA"$}) }

          it { is_expected.to contain_exec('generate dh param test_server').with_creates("#{server_directory}/test_server/easy-rsa/keys/dh.pem") }
        end
      when 'Debian'
        server_directory = '/etc/openvpn'

        context 'creating a server with the minimum parameters' do
          let(:params) do
            {
              'country'      => 'CO',
              'province'     => 'ST',
              'city'         => 'Some City',
              'organization' => 'example.org',
              'email'        => 'testemail@example.org'
            }
          end

          # Files associated with a server config

          it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with(mode: '0550') }
          it {
            is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/keys/crl.pem").
              with(ensure: 'link', target: "#{server_directory}/test_server/crl.pem")
          }
          it {
            is_expected.to contain_file("#{server_directory}/test_server/keys").
              with(ensure: 'link', target: "#{server_directory}/test_server/easy-rsa/keys")
          }

          # Execs to working with certificates

          if facts[:os]['release']['major'] =~ %r{10|11|20.04}
            it { is_expected.to contain_exec('generate dh param test_server').with_creates("#{server_directory}/test_server/easy-rsa/keys/dh.pem") }
          else
            it { is_expected.to contain_exec('generate dh param test_server').with_creates("#{server_directory}/test_server/easy-rsa/keys/dh2048.pem") }
          end
          it { is_expected.to contain_exec('initca test_server') }
          it { is_expected.to contain_exec('generate server cert test_server') }
          it { is_expected.to contain_exec('create crl.pem on test_server') }
          it { is_expected.not_to contain_exec('update crl.pem on test_server') }

          if facts[:os]['release']['major'] =~ %r{10|11|20.04}
            it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export EASYRSA_CA_EXPIRE=3650$}) }
            it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export EASYRSA_CERT_EXPIRE=3650$}) }
            it { is_expected.not_to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export EASYRSA_REQ_CN"$}) }
            # Missing key_name
            it { is_expected.not_to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export EASYRSA_REQ_OU"$}) }
          else
            it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export CA_EXPIRE=3650$}) }
            it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export KEY_EXPIRE=3650$}) }
            it { is_expected.not_to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{KEY_CN}) }
            it { is_expected.not_to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{KEY_NAME}) }
            it { is_expected.not_to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{KEY_OU}) }
          end
        end

        context 'creating a ca setting all parameters' do
          let(:params) do
            {
              'country' => 'CO',
              'province'        => 'ST',
              'city'            => 'Some City',
              'organization'    => 'example.org',
              'email'           => 'testemail@example.org',
              'group'           => 'someone',
              'ssl_key_size'    => 2048,
              'common_name'     => 'mylittlepony',
              'ca_expire'       => 365,
              'key_expire'      => 365,
              'key_cn'          => 'yolo',
              'key_name'        => 'burp',
              'key_ou'          => 'NSA'
            }
          end

          if facts[:os]['release']['major'] =~ %r{10|11|20.04}
            it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export EASYRSA_CA_EXPIRE=365$}) }
            it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export EASYRSA_CERT_EXPIRE=365$}) }
            it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export EASYRSA_REQ_CN="yolo"$}) }
            # Missing key_name
            it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export EASYRSA_REQ_OU="NSA"$}) }
          else
            it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export CA_EXPIRE=365$}) }
            it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export KEY_EXPIRE=365$}) }
            it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export KEY_CN="yolo"$}) }
            it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export KEY_NAME="burp"$}) }
            it { is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/vars").with_content(%r{^export KEY_OU="NSA"$}) }
          end

          if facts[:os]['release']['major'] =~ %r{10|11|20.04}
            it { is_expected.to contain_exec('generate dh param test_server').with_creates("#{server_directory}/test_server/easy-rsa/keys/dh.pem") }
          else
            it { is_expected.to contain_exec('generate dh param test_server').with_creates("#{server_directory}/test_server/easy-rsa/keys/dh2048.pem") }
          end
        end

        context 'when Debian based machine' do
          let(:params) do
            {
              'country' => 'CO',
              'province'      => 'ST',
              'city'          => 'Some City',
              'organization'  => 'example.org',
              'email'         => 'testemail@example.org'
            }
          end

          if facts[:os]['release']['major'] =~ %r{10|11|20.04}
            it {
              is_expected.to contain_file("#{server_directory}/test_server/easy-rsa/openssl.cnf").with(
                'ensure'  => 'link',
                'target'  => "#{server_directory}/test_server/easy-rsa/openssl-1.0.cnf",
                'recurse' => nil,
                'group'   => 'nogroup'
              )
            }
          end

          it {
            is_expected.to contain_file("#{server_directory}/test_server/crl.pem").with(
              'mode'    => '0640',
              'group'   => 'nogroup'
            )
          }
        end
      end
    end
  end
end
