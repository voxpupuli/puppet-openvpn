require 'spec_helper'

describe 'openvpn::ca', :type => :define do

  let(:title) { 'test_server' }

  let(:facts) { {
    :ipaddress_eth0 => '1.2.3.4',
    :network_eth0 => '1.2.3.0',
    :netmask_eth0 => '255.255.255.0',
    :concat_basedir => '/var/lib/puppet/concat',
    :osfamily => 'Debian',
    :operatingsystem => 'Ubuntu',
    :operatingsystemrelease => '12.04',
  } }

  context "creating a server with the minimum parameters" do
    let(:params) { {
      'country'       => 'CO',
      'province'      => 'ST',
      'city'          => 'Some City',
      'organization'  => 'example.org',
      'email'         => 'testemail@example.org'
    } }

    # Files associated with a server config

    it { should contain_file('/etc/openvpn/test_server/easy-rsa/clean-all').with(:mode => '0550') }
    it { should contain_file('/etc/openvpn/test_server/easy-rsa/build-dh').with(:mode => '0550') }
    it { should contain_file('/etc/openvpn/test_server/easy-rsa/pkitool').with(:mode => '0550') }
    it { should contain_file('/etc/openvpn/test_server/easy-rsa/vars').with(:mode => '0550') }
    it { should contain_file('/etc/openvpn/test_server/easy-rsa/openssl.cnf').
         with(:recurse =>nil, :group =>'nogroup') }
    it { should contain_file('/etc/openvpn/test_server/easy-rsa/keys/crl.pem').
         with(:ensure =>'link', :target =>'/etc/openvpn/test_server/crl.pem') }
    it { should contain_file('/etc/openvpn/test_server/keys').
         with(:ensure =>'link', :target =>'/etc/openvpn/test_server/easy-rsa/keys') }

    # Execs to working with certificates
    it { should contain_exec('copy easy-rsa to openvpn config folder test_server').with(
      'command' => '/bin/cp -r /usr/share/doc/openvpn/examples/easy-rsa/2.0 /etc/openvpn/test_server/easy-rsa'
    )}
    it { should contain_exec('generate dh param test_server').with_creates('/etc/openvpn/test_server/easy-rsa/keys/dh1024.pem') }
    it { should contain_exec('initca test_server') }
    it { should contain_exec('generate server cert test_server') }
    it { should contain_exec('create crl.pem on test_server') }

    it { should contain_file('/etc/openvpn/test_server/easy-rsa/vars').with_content(/^export CA_EXPIRE=3650$/) }
    it { should contain_file('/etc/openvpn/test_server/easy-rsa/vars').with_content(/^export KEY_EXPIRE=3650$/) }
    it { should_not contain_file('/etc/openvpn/test_server/easy-rsa/vars').with_content(/KEY_CN/) }
    it { should_not contain_file('/etc/openvpn/test_server/easy-rsa/vars').with_content(/KEY_NAME/) }
    it { should_not contain_file('/etc/openvpn/test_server/easy-rsa/vars').with_content(/KEY_OU/) }
  end

  context "creating a ca setting all parameters" do
    let(:params) { {
      'country'         => 'CO',
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
      'key_ou'          => 'NSA',
    } }

    let(:facts) { {
      :ipaddress_eth0 => '1.2.3.4',
      :network_eth0   => '1.2.3.0',
      :netmask_eth0   => '255.255.255.0',
      :concat_basedir => '/var/lib/puppet/concat',
      :osfamily       => 'Debian',
      :operatingsystem      => 'Ubuntu',
      :operatingsystemrelease => '12.04',
    } }

    it { should contain_file('/etc/openvpn/test_server/easy-rsa/vars').with_content(/^export CA_EXPIRE=365$/) }
    it { should contain_file('/etc/openvpn/test_server/easy-rsa/vars').with_content(/^export KEY_EXPIRE=365$/) }
    it { should contain_file('/etc/openvpn/test_server/easy-rsa/vars').with_content(/^export KEY_CN="yolo"$/) }
    it { should contain_file('/etc/openvpn/test_server/easy-rsa/vars').with_content(/^export KEY_NAME="burp"$/) }
    it { should contain_file('/etc/openvpn/test_server/easy-rsa/vars').with_content(/^export KEY_OU="NSA"$/) }

    it { should contain_exec('generate dh param test_server').with_creates('/etc/openvpn/test_server/easy-rsa/keys/dh2048.pem') }
  end

  context "when RedHat based machine" do
    let(:params) { {
      'country'       => 'CO',
      'province'      => 'ST',
      'city'          => 'Some City',
      'organization'  => 'example.org',
      'email'         => 'testemail@example.org'
    } }

    let(:facts) do
      {
        osfamily: 'RedHat',
        concat_basedir: '/var/lib/puppet/concat',
        operatingsystemrelease: '7.0',
      }
    end

    it { should contain_package('easy-rsa').with('ensure' => 'present') }
    it { should contain_exec('copy easy-rsa to openvpn config folder test_server').with(
      'command' => '/bin/cp -r /usr/share/easy-rsa/2.0 /etc/openvpn/test_server/easy-rsa'
    )}

    it { should contain_file('/etc/openvpn/test_server/easy-rsa/openssl.cnf').with(
      'ensure'  => 'link',
      'target'  => '/etc/openvpn/test_server/easy-rsa/openssl-1.0.0.cnf',
      'recurse' => nil,
      'group'   => 'nobody'
    )}

    it { should contain_file('/etc/openvpn/test_server/crl.pem').with(
      'mode'    => '0640',
      'group'   => 'nobody'
    )}

  end

  context "when Debian based machine" do
    let(:params) { {
      'country'       => 'CO',
      'province'      => 'ST',
      'city'          => 'Some City',
      'organization'  => 'example.org',
      'email'         => 'testemail@example.org'
    } }

    let(:facts) do
      {
        osfamily: 'Debian',
        operatingsystem: 'Debian',
        concat_basedir: '/var/lib/puppet/concat',
        operatingsystemrelease: '7.0',
      }
    end

    shared_examples_for 'a newer version than wheezy' do
      it { should contain_package('easy-rsa').with('ensure' => 'present') }
      it { should contain_exec('copy easy-rsa to openvpn config folder test_server').with(
        'command' => '/bin/cp -r /usr/share/easy-rsa/ /etc/openvpn/test_server/easy-rsa'
      )}
    end
    context "when jessie/sid" do
      before do
        facts[:operatingsystem] = 'Debian'
        facts[:operatingsystemrelease] = '8.0.1'
      end
      it_behaves_like 'a newer version than wheezy'
    end

    context 'when ubuntu 13.10' do
      before do
        facts[:operatingsystem] = 'Ubuntu'
        facts[:operatingsystemrelease] = '13.10'
      end
      it_behaves_like 'a newer version than wheezy'
    end

    context 'when ubuntu 14.04' do
      before do
        facts[:operatingsystem] = 'Ubuntu'
        facts[:operatingsystemrelease] = '14.04'
      end
      it_behaves_like 'a newer version than wheezy'
    end


    it { should contain_file('/etc/openvpn/test_server/easy-rsa/openssl.cnf').with(
      'ensure'  => 'link',
      'target'  => '/etc/openvpn/test_server/easy-rsa/openssl-1.0.0.cnf',
      'recurse' => nil,
      'group'   => 'nogroup'
    )}

    it { should contain_exec('copy easy-rsa to openvpn config folder test_server').with(
      'command' => '/bin/cp -r /usr/share/doc/openvpn/examples/easy-rsa/2.0 /etc/openvpn/test_server/easy-rsa'
    )}

    it { should contain_file('/etc/openvpn/test_server/crl.pem').with(
      'mode'    => '0640',
      'group'   => 'nogroup'
    )}

  end

end
