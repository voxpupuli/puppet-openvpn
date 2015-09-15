require 'spec_helper'

describe 'openvpn::server', :type => :define do

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

  context 'creating a server without any parameter' do
    let(:params) { { } }
    it { expect { should contain_file('/etc/openvpn/test_server') }.to raise_error }
  end

  context 'creating a server partial parameters: country' do
    let(:params) { { 'country' => 'CO' } }
    it { expect { should contain_file('/etc/openvpn/test_server') }.to raise_error }
  end

  context 'creating a server partial parameters: country, province' do
    let(:params) { {
      'country'       => 'CO',
      'province'      => 'ST',
    } }
    it { expect { should contain_file('/etc/openvpn/test_server') }.to raise_error }
  end

  context 'creating a server partial parameters: country, province, city' do
    let(:params) { {
      'country'       => 'CO',
      'province'      => 'ST',
      'city'          => 'Some City',
    } }
    it { expect { should contain_file('/etc/openvpn/test_server') }.to raise_error }
  end

  context 'creating a server partial parameters: country, province, city, organization' do
    let(:params) { {
      'country'       => 'CO',
      'province'      => 'ST',
      'city'          => 'Some City',
      'organization'  => 'example.org',
    } }
    it { expect { should contain_file('/etc/openvpn/test_server') }.to raise_error }
  end

  context "creating a server with the minimum parameters" do
    let(:params) { {
      'country'       => 'CO',
      'province'      => 'ST',
      'city'          => 'Some City',
      'organization'  => 'example.org',
      'email'         => 'testemail@example.org'
    } }

    # Files associated with a server config
    it { should contain_file('/etc/openvpn/test_server').
         with(:ensure =>'directory', :mode =>'0750', :group =>'nogroup') }
    it { should contain_file('/etc/openvpn/test_server/client-configs').
         with(:ensure =>'directory', :mode =>'0750', :recurse =>true, :group =>'nogroup') }
    it { should contain_file('/etc/openvpn/test_server/download-configs').
         with(:ensure =>'directory', :mode =>'0750', :recurse =>true, :group =>'nogroup') }
    it { should contain_file('/etc/openvpn/test_server/auth').
         with(:ensure =>'directory', :mode =>'0750', :recurse =>true, :group =>'nogroup') }

    # OpenVPN easy-rsa CA
    it { should contain_openvpn__ca('test_server').with(params) }

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
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^status\s+/var/log/openvpn/test_server-status\.log$}) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^dev\s+tun0$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^local\s+1\.2\.3\.4$/) }
    it { should_not contain_file('/etc/openvpn/test_server.conf').with_content(/^ifconfig-pool-persist/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^crl-verify\s+\/etc\/openvpn\/test_server\/crl.pem$/) }

    it { should_not contain_file('/etc/openvpn/test_server.conf').with_content(/verb/) }
    it { should_not contain_file('/etc/openvpn/test_server.conf').with_content(/cipher/) }
    it { should_not contain_file('/etc/openvpn/test_server.conf').with_content(/persist-key/) }
    it { should_not contain_file('/etc/openvpn/test_server.conf').with_content(/persist-tun/) }
    it { should_not contain_file('/etc/openvpn/test_server.conf').with_content(%r{^duplicate-cn$}) }
    it { should_not contain_file('/etc/openvpn/test_server.conf').with_content(/^ns-cert-type server/) }
    it { should_not contain_file('/etc/openvpn/test_server.conf').with_content(%r{^tls-auth}) }
    it { should_not contain_file('/etc/openvpn/test_server.conf').with_content(%r{^fragment}) }

  end

  context "creating a server setting all parameters" do
    let(:params) { {
      'country'         => 'CO',
      'province'        => 'ST',
      'city'            => 'Some City',
      'organization'    => 'example.org',
      'email'           => 'testemail@example.org',
      'compression'     => 'fake_compression',
      'port'            => '123',
      'proto'           => 'udp',
      'group'           => 'someone',
      'user'            => 'someone',
      'logfile'         => '/var/log/openvpn/test_server.log',
      'status_log'      => '/tmp/test_server_status.log',
      'dev'             => 'tun1',
      'up'              => '/tmp/up',
      'down'            => '/tmp/down',
      'local'           => '2.3.4.5',
      'ipp'             => true,
      'server'          => '2.3.4.0 255.255.0.0',
      'server_ipv6'	=> 'fe80:1337:1337:1337::/64',
      'push'            => [ 'dhcp-option DNS 172.31.0.30', 'route 172.31.0.0 255.255.0.0' ],
      'route'           => [ '192.168.30.0 255.255.255.0', '192.168.35.0 255.255.0.0' ],
      'route_ipv6'      => [ '2001:db8:1234::/64', '2001:db8:abcd::/64' ],
      'keepalive'       => '10 120',
      'topology'        => 'subnet',
      'ssl_key_size'    => 2048,
      'management'      => true,
      'management_ip'   => '1.3.3.7',
      'management_port' => 1337,
      'common_name'     => 'mylittlepony',
      'ca_expire'       => 365,
      'key_expire'      => 365,
      'key_cn'          => 'yolo',
      'key_name'        => 'burp',
      'key_ou'          => 'NSA',
      'verb'            => 'mute',
      'cipher'          => 'DES-CBC',
      'tls_cipher'      => 'TLS-DHE-RSA-WITH-AES-256-CBC-SHA',
      'persist_key'     => true,
      'persist_tun'     => true,
      'duplicate_cn'    => true,
      'tls_auth'        => true,
      'tls_server'      => true,
      'fragment'        => 1412,
      'custom_options'  => { 'this' => 'that' },
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

    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^mode\s+server$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^client-config-dir\s+/etc/openvpn/test_server/client-configs$}) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^ca\s+/etc/openvpn/test_server/keys/ca.crt$}) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^cert\s+/etc/openvpn/test_server/keys/mylittlepony.crt$}) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^key\s+/etc/openvpn/test_server/keys/mylittlepony.key$}) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^dh\s+/etc/openvpn/test_server/keys/dh2048.pem$}) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^proto\s+udp$/) }
    it { should_not contain_file('/etc/openvpn/test_server.conf').with_content(/^proto\s+tls-server$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^port\s+123$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^fake_compression$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^group\s+someone$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^user\s+someone$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^log\-append\s+/var/log/openvpn/test_server\.log$}) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^status\s+/tmp/test_server_status\.log$}) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^dev\s+tun1$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^local\s+2\.3\.4\.5$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^server\s+2\.3\.4\.0\s+255\.255\.0\.0$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^server-ipv6\s+fe80\:1337\:1337\:1337\:\:\/64$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^push\s+"dhcp-option\s+DNS\s+172\.31\.0\.30"$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^push\s+"route\s+172\.31\.0\.0\s+255\.255\.0\.0"$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^route\s+192.168.30.0\s+255.255.255.0$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^route\s+192.168.35.0\s+255.255.0.0$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^route-ipv6\s+2001\:db8\:1234\:\:\/64$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^route-ipv6\s+2001\:db8\:abcd\:\:\/64$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^keepalive\s+10\s+120$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^topology\s+subnet$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^management\s+1.3.3.7 1337$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^verb mute$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^cipher DES-CBC$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^tls-cipher\s+TLS-DHE-RSA-WITH-AES-256-CBC-SHA$/)}
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^persist-key$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^persist-tun$/) }

    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^up "/tmp/up"$}) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^down "/tmp/down"$}) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^script-security 2$}) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^duplicate-cn$}) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^tls-server$}) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^tls-auth\s+/etc/openvpn/test_server/keys/ta.key$}) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^key-direction 0$}) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^this that$}) }

    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^fragment 1412$}) }

    it { should_not contain_file('/etc/openvpn/test_server.conf').with_content(/^server-poll-timeout/) }
    it { should_not contain_file('/etc/openvpn/test_server.conf').with_content(/^ping-timer-rem/) }
    it { should_not contain_file('/etc/openvpn/test_server.conf').with_content(/^sndbuf/) }
    it { should_not contain_file('/etc/openvpn/test_server.conf').with_content(/^rcvbuf/) }

    # OpenVPN easy-rsa CA
    it { should contain_openvpn__ca('test_server').
         with(:country      => 'CO',
              :province     => 'ST',
              :city         => 'Some City',
              :organization => 'example.org',
              :email        => 'testemail@example.org',
              :group        => 'someone',
              :ssl_key_size => 2048,
              :common_name  => 'mylittlepony',
              :ca_expire    => 365,
              :key_expire   => 365,
              :key_cn       => 'yolo',
              :key_name     => 'burp',
              :key_ou       => 'NSA',
              :tls_auth     => true)
    }

  end

  context "creating a server in client mode" do
    let(:title) { 'test_client' }
    let(:nobind) { false }
    let(:params) { {
      'remote'              => ['vpn.example.com 12345'],
      'server_poll_timeout' => 1,
      'ping_timer_rem'      => true,
      'tls_auth'            => true,
      'tls_client'          => true,
      'nobind'              => nobind,
    } }

    context 'nobind is true' do
      let(:nobind) { true }

      it { should contain_file('/etc/openvpn/test_client.conf').with_content(%r{^nobind$}) }
      it { should_not contain_file('/etc/openvpn/test_client.conf').with_content(%r{port\s+\d+}) }
    end

    let(:facts) { {
      :ipaddress_eth0 => '1.2.3.4',
      :network_eth0   => '1.2.3.0',
      :netmask_eth0   => '255.255.255.0',
      :concat_basedir => '/var/lib/puppet/concat',
      :osfamily       => 'Debian',
      :operatingsystem      => 'Ubuntu',
      :operatingsystemrelease => '12.04',
    } }
    it { should contain_file('/etc/openvpn/test_client.conf').with_content(/^client$/) }
    it { should contain_file('/etc/openvpn/test_client.conf').
         with_content(/^remote\s+vpn.example.com\s+12345$/) }
    it { should contain_file('/etc/openvpn/test_client.conf').with_content(/^server-poll-timeout\s+1$/) }
    it { should contain_file('/etc/openvpn/test_client.conf').with_content(/^ping-timer-rem$/) }
    it { should contain_file('/etc/openvpn/test_client.conf').
         with_content(%r{^ca /etc/openvpn/test_client/keys/ca.crt$}) }
    it { should contain_file('/etc/openvpn/test_client.conf').
         with_content(%r{^cert /etc/openvpn/test_client/keys/test_client.crt$}) }
    it { should contain_file('/etc/openvpn/test_client.conf').
         with_content(%r{^key /etc/openvpn/test_client/keys/test_client.key$}) }
    it { should contain_file('/etc/openvpn/test_client/keys').
         with(:ensure =>'directory', :mode =>'0750', :group =>'nogroup') }
    it { should contain_file('/etc/openvpn/test_client.conf').with_content(/^ns-cert-type server/) }
    it { should_not contain_file('/etc/openvpn/test_client.conf').with_content(/^mode\s+server$/) }
    it { should_not contain_file('/etc/openvpn/test_client.conf').with_content(/^client-config-dir/) }
    it { should_not contain_file('/etc/openvpn/test_client.conf').with_content(/^dh/) }
    it { should contain_file('/etc/openvpn/test_client.conf').with_content(%r{^tls-client$}) }
    it { should contain_file('/etc/openvpn/test_client.conf').with_content(%r{^key-direction 1$}) }
    it { should_not contain_file('/etc/openvpn/test_client.conf').with_content(%r{nobind}) }
    it { should contain_file('/etc/openvpn/test_client.conf').with_content(%r{^port\s+\d+$}) }

    it { should_not contain_openvpn__ca('test_client') }
  end

  context "when altering send and receive buffers" do
    let(:params) { {
      'country'       => 'CO',
      'province'      => 'ST',
      'city'          => 'Some City',
      'organization'  => 'example.org',
      'email'         => 'testemail@example.org',
      'sndbuf'        => 393216,
      'rcvbuf'        => 393215,
    } }

    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^sndbuf\s+393216$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^rcvbuf\s+393215$/) }
  end

  context "when using shared ca" do
    let(:params) { {
      'shared_ca'       => 'my_already_existing_ca',
    } }
    let(:pre_condition) { '
      openvpn::ca{ "my_already_existing_ca":
          common_name   => "custom_common_name",
          country       => "CO",
          province      => "ST",
          city          => "Some City",
          organization  => "example.org",
          email         => "testemail@example.org"
    }' }

    it { should contain_openvpn__ca('my_already_existing_ca') }

    # Check that certificate files point to the provide CA
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^mode\s+server$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^client\-config\-dir\s+\/etc\/openvpn\/test_server\/client\-configs$/) }

    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^ca\s+\/etc\/openvpn\/my_already_existing_ca\/keys\/ca.crt$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^cert\s+\/etc\/openvpn\/my_already_existing_ca\/keys\/custom_common_name.crt$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^key\s+\/etc\/openvpn\/my_already_existing_ca\/keys\/custom_common_name.key$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^dh\s+\/etc\/openvpn\/my_already_existing_ca\/keys\/dh1024.pem$/) }
  end

  context "when using not existed shared ca" do
    let(:params) { {
      'shared_ca'       => 'my_already_existing_ca',
    } }
    it { expect { should compile }.to raise_error }
  end

  context "when RedHat based machine" do
    let(:params) { {
      'country'       => 'CO',
      'province'      => 'ST',
      'city'          => 'Some City',
      'organization'  => 'example.org',
      'email'         => 'testemail@example.org',
      'pam'           => true,
    } }

    let(:facts) { { :osfamily => 'RedHat',
                    :concat_basedir => '/var/lib/puppet/concat' } }

    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^group\s+nobody$}) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^plugin /usr/lib64/openvpn/plugin/lib/openvpn-auth-pam.so login$}) }
  end

  context "when Debian based machine" do
    let(:params) { {
      'country'       => 'CO',
      'province'      => 'ST',
      'city'          => 'Some City',
      'organization'  => 'example.org',
      'email'         => 'testemail@example.org',
      'pam'           => true,
    } }

    let(:facts) { { :osfamily => 'Debian', :operatingsystem => 'Debian', :concat_basedir => '/var/lib/puppet/concat' } }

    it { should contain_file('/etc/openvpn/test_server.conf').with_content(/^group\s+nogroup$/) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^plugin /usr/lib/openvpn/openvpn-auth-pam.so login$}) }

    context 'enabled autostart_all' do
      let(:pre_condition) { 'class { "openvpn": autostart_all => true }' }

      it { should_not contain_concat__fragment('openvpn.default.autostart.test_server') }
    end

    context 'disabled autostart_all' do
      let(:pre_condition) { 'class { "openvpn": autostart_all => false }' }

      it { should_not contain_concat__fragment('openvpn.default.autostart.test_server') }

      context 'but machine has autostart' do
        before { params['autostart'] = true }
        it { should contain_concat__fragment('openvpn.default.autostart.test_server').with(
          'content' => "AUTOSTART=\"$AUTOSTART test_server\"\n",
          'target'  => '/etc/default/openvpn'
        )}
      end
    end
  end

  context 'ldap' do
    before do
      facts[:osfamily] = 'Debian'
      facts[:operatingsystem] = 'Debian'
      facts[:operatingsystemrelease] = '8.0.0'
    end
    let(:params) { {
      'country'       => 'CO',
      'province'      => 'ST',
      'city'          => 'Some City',
      'organization'  => 'example.org',
      'email'         => 'testemail@example.org',

      'username_as_common_name' => true,
      'client_cert_not_required' => true,

      'ldap_enabled'   => true,
      'ldap_server'    => 'ldaps://ldap.example.org:636',
      'ldap_binddn'    => 'dn=root,dc=example,dc=org',
      'ldap_bindpass'  => 'secret password',
      'ldap_u_basedn'  => 'ou=people,dc=example,dc=org',
      'ldap_u_filter'  => 'call me user filter',
      'ldap_g_basedn'  => 'ou=groups,dc=example,dc=org',
      'ldap_gmember'   => true,
      'ldap_g_filter'  => 'call me group filter',
      'ldap_memberatr' => 'iCanTyping',

      'ldap_tls_enable'           => true,
      'ldap_tls_ca_cert_file'     => '/somewhere/ca.crt',
      'ldap_tls_ca_cert_dir'      => '/etc/ssl/certs',
      'ldap_tls_client_cert_file' => '/somewhere/client.crt',
      'ldap_tls_client_key_file'  => '/somewhere/client.key',
    } }

    it { should contain_package('openvpn-auth-ldap').with('ensure' => 'present') }

    it { should contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+URL ldaps://ldap\.example\.org:636$}) }
    it { should contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+BindDN dn=root,dc=example,dc=org$}) }
    it { should contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+Password secret password$}) }
    it { should contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+BaseDN ou=people,dc=example,dc=org$}) }
    it { should contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+SearchFilter "call me user filter"$}) }
    it { should contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+RequireGroup true$}) }

    it { should contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+BaseDN ou=groups,dc=example,dc=org$}) }
    it { should contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+SearchFilter "call me group filter"$}) }
    it { should contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+MemberAttribute iCanTyping$}) }

    it { should contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+TLSEnable yes$}) }
    it { should contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+TLSCACertFile /somewhere/ca.crt$}) }
    it { should contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+TLSCACertDir /etc/ssl/certs$}) }
    it { should contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+TLSCertFile /somewhere/client.crt$}) }
    it { should contain_file('/etc/openvpn/test_server/auth/ldap.conf').with_content(%r{^\s+TLSKeyFile /somewhere/client.key$}) }

    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^plugin /usr/lib/openvpn/openvpn-auth-ldap.so "/etc/openvpn/test_server/auth/ldap.conf"$}) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^username-as-common-name$}) }
    it { should contain_file('/etc/openvpn/test_server.conf').with_content(%r{^client-cert-not-required$}) }

  end

  context 'systemd enabled RedHat' do
    let(:pre_condition) { "class { 'openvpn': manage_service => #{manage_service} }" }
    let(:facts) do
      {
        :concat_basedir         => '/var/lib/puppet/concat',
        :osfamily               => 'RedHat',
        :operatingsystemrelease => '7.0',
      }
    end
    let(:params) do
      {
        'country'       => 'CO',
        'province'      => 'ST',
        'city'          => 'Some City',
        'organization'  => 'example.org',
        'email'         => 'testemail@example.org'
      }
    end


    context 'service is managed' do
      let(:manage_service) { true }
      it { should contain_service('openvpn@test_server').with(
        :ensure => 'running',
        :enable => true,
      )}
    end

    context 'service is unmanaged' do
      let(:manage_service) { false }
      it { should_not contain_service('openvpn@test_server').with(
        :ensure => 'running',
        :enable => true,
      )}
    end
  end

  context 'systemd enabled Debian' do
    let(:pre_condition) { "class { 'openvpn': manage_service => #{manage_service} }" }
    let(:facts) do
      {
        :concat_basedir         => '/var/lib/puppet/concat',
        :osfamily               => 'Debian',
        :operatingsystem        => 'Debian',
        :operatingsystemrelease => '8.0',
      }
    end

    let(:params) do
      {
        'country'       => 'CO',
        'province'      => 'ST',
        'city'          => 'Some City',
        'organization'  => 'example.org',
        'email'         => 'testemail@example.org'
      }
    end

    context 'service is managed' do
      let(:manage_service) { true }
      it { should contain_service('openvpn@test_server').with(
        :ensure => 'running',
        :enable => true,
      )}
    end

    context 'service is unmanaged' do
      let(:manage_service) { false }
      it { should_not contain_service('openvpn@test_server').with(
        :ensure => 'running',
        :enable => true,
      )}
    end
  end
end
