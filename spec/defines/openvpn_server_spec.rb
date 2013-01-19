require 'spec_helper'

describe 'openvpn::server', :type => :define do

  let(:title) { 'test_server' }

  context "creating a server with the minimum parameters" do
    let(:params) { {
      'country'       => 'CO',
      'province'      => 'ST',
      'city'          => 'Some City',
      'organization'  => 'example.org',
      'email'         => 'testemail@example.org'
    } }

    let (:facts) { {
      :ipaddress_eth0 => '1.2.3.4',
      :network_eth0   => '1.2.3.0',
      :netmask_eth0   => '255.255.255.0',
      :concat_basedir => '/var/lib/puppet/concat',
      :osfamily       => 'anything_else'
    } }

    # Files associated with a server config
    it { should contain_file('/etc/openvpn/test_server').with('ensure' => 'directory')}
    it { should contain_file('/etc/openvpn/test_server/client-configs').with('ensure' => 'directory')}
    it { should contain_file('/etc/openvpn/test_server/download-configs').with('ensure' => 'directory')}
    it { should contain_file('/etc/openvpn/test_server/easy-rsa/vars')}
    it { should contain_file('/etc/openvpn/test_server/easy-rsa/openssl.cnf')}
    it { should contain_file('/etc/openvpn/test_server/keys').with(
      'ensure'  => 'link',
      'target'  => '/etc/openvpn/test_server/easy-rsa/keys'
    )}

    # Execs to working with certificates
    it { should contain_exec('copy easy-rsa to openvpn config folder test_server').with(
      'command' => '/bin/cp -r /usr/share/doc/openvpn/examples/easy-rsa/2.0 /etc/openvpn/test_server/easy-rsa'
    )}
    it { should contain_exec('generate dh param test_server') }
    it { should contain_exec('initca test_server') }
    it { should contain_exec('generate server cert test_server') }

    # VPN server config file itself
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^mode\s+server$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^client\-config\-dir\s+\/etc\/openvpn\/test_server\/client\-configs$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^ca\s+\/etc\/openvpn\/test_server\/keys\/ca.crt$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^cert\s+\/etc\/openvpn\/test_server\/keys\/server.crt$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^key\s+\/etc\/openvpn\/test_server\/keys\/server.key$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^dh\s+\/etc\/openvpn\/test_server\/keys\/dh1024.pem$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^proto\s+tcp-server$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^tls-server$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^port\s+1194$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^comp-lzo$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^group\s+nogroup$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^user\s+nobody$/) }
    it { should_not contain_file('/etc/openvpn/test_server.conf').with_content(/^log\-append\s+test_server\/openvpn\.log$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^status\s+test_server\/openvpn\-status\.log$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^dev\s+tun0$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^local\s+1\.2\.3\.4$/) }
    it { should_not contain_file('/etc/openvpn/test_server.conf').with_content(/^ifconfig-pool-persist/) }
  end

  context "creating a server setting all parameters" do
    let(:params) { {
      'country'       => 'CO',
      'province'      => 'ST',
      'city'          => 'Some City',
      'organization'  => 'example.org',
      'email'         => 'testemail@example.org',
      'compression'   => 'fake_compression',
      'port'          => '123',
      'proto'         => 'udp',
      'group'         => 'someone',
      'user'          => 'someone',
      'logfile'       => '/var/log/openvpn/test_server.log',
      'status_log'    => '/var/log/openvpn/test_server_status.log',
      'dev'           => 'tun1',
      'local'         => '2.3.4.5',
      'ipp'           => true,
      'server'        => '2.3.4.0 255.255.0.0',
      'push'          => [ 'dhcp-option DNS 172.31.0.30', 'route 172.31.0.0 255.255.0.0' ]
    } }

    let (:facts) { {
      :ipaddress_eth0 => '1.2.3.4',
      :network_eth0   => '1.2.3.0',
      :netmask_eth0   => '255.255.255.0',
      :concat_basedir => '/var/lib/puppet/concat'
    } }

    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^mode\s+server$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^client\-config\-dir\s+\/etc\/openvpn\/test_server\/client\-configs$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^ca\s+\/etc\/openvpn\/test_server\/keys\/ca.crt$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^cert\s+\/etc\/openvpn\/test_server\/keys\/server.crt$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^key\s+\/etc\/openvpn\/test_server\/keys\/server.key$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^dh\s+\/etc\/openvpn\/test_server\/keys\/dh1024.pem$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^proto\s+udp-server$/) }
    it { should_not contain_file('/etc/openvpn/test_server.conf').with_content(/^proto\s+tls-server$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^port\s+123$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^fake_compression$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^group\s+someone$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^user\s+someone$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^log\-append\s+\/var\/log\/openvpn\/test_server\.log$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^status\s+\/var\/log\/openvpn\/test_server_status\.log$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^dev\s+tun1$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^local\s+2\.3\.4\.5$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^server\s+2\.3\.4\.0\s+255\.255\.0\.0$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^push\s+dhcp-option\s+DNS\s+172\.31\.0\.30$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^push\s+route\s+172\.31\.0\.0\s+255\.255\.0\.0$/) }
  end

  context "when RedHat based machine" do
    let(:params) { {
      'country'       => 'CO',
      'province'      => 'ST',
      'city'          => 'Some City',
      'organization'  => 'example.org',
      'email'         => 'testemail@example.org'
    } }

    let(:facts) { { :osfamily => 'RedHat', :concat_basedir => '/var/lib/puppet/concat' } }

    it { should contain_file('/etc/openvpn/test_server/easy-rsa/openssl.cnf').with(
      'ensure'  => 'link',
      'target'  => '/etc/openvpn/test_server/easy-rsa/openssl-1.0.0.cnf'
    )}

    it { should contain_exec('copy easy-rsa to openvpn config folder test_server').with(
      'command' => '/bin/cp -r /usr/share/doc/openvpn-2.2.2/easy-rsa/2.0 /etc/openvpn/test_server/easy-rsa'
    )}
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^group\s+nobody$/) }

  end

  context "when Debian based machine" do
    let(:params) { {
      'country'       => 'CO',
      'province'      => 'ST',
      'city'          => 'Some City',
      'organization'  => 'example.org',
      'email'         => 'testemail@example.org'
    } }

    let(:facts) { { :osfamily => 'Debian', :concat_basedir => '/var/lib/puppet/concat' } }

    it { should contain_file('/etc/openvpn/test_server/easy-rsa/openssl.cnf').with(
      'ensure'  => 'link',
      'target'  => '/etc/openvpn/test_server/easy-rsa/openssl-1.0.0.cnf'
    )}

    it { should contain_exec('copy easy-rsa to openvpn config folder test_server').with(
      'command' => '/bin/cp -r /usr/share/doc/openvpn/examples/easy-rsa/2.0 /etc/openvpn/test_server/easy-rsa'
    )}

    # Configure to start vpn session
    it { should contain_concat__fragment('openvpn.default.autostart.test_server').with(
      'content' => "AUTOSTART=\"$AUTOSTART test_server\"\n",
      'target'  => '/etc/default/openvpn'
    )}

    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^group\s+nogroup$/) }

  end

end
