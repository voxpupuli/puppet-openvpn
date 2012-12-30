require 'spec_helper'
 
describe 'openvpn::server', :type => :define do
  
  let(:title) { 'test_server' }
  let(:params) { {
    'country'       => 'CO',
    'province'      => 'ST',
    'city'          => 'Some City',
    'organization'  => 'example.org',
    'email'         => 'testemail@example.org'
  } }

  let (:facts) { { :concat_basedir => '/var/lib/puppet/concat' } }
  
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
  
  it { should contain_concat__fragment('openvpn.default.autostart.test_server').with(
    'content' => "AUTOSTART=\"$AUTOSTART test_server\"\n",
    'target'  => '/etc/default/openvpn'
  )}
  
  # Execs to working with certificates
  it { should contain_exec('copy easy-rsa to openvpn config folder test_server').with(
    'command' => '/bin/cp -r /usr/share/doc/openvpn/examples/easy-rsa/2.0 /etc/openvpn/test_server/easy-rsa'
  )}
  it { should contain_exec('generate dh param test_server') }
  it { should contain_exec('initca test_server') }
  it { should contain_exec('generate server cert test_server') }
  
  # Options that should be set
  it { should contain_openvpn__option('client-config-dir test_server').with(
    'server'  => 'test_server',
    'key'     => 'client-config-dir',
    'value'   => '/etc/openvpn/test_server/client-configs'
  )}
  it { should contain_openvpn__option('mode test_server').with(
    'server'  => 'test_server', 
    'key'     => 'mode', 
    'value'   => 'server'
  )}
  it { should contain_openvpn__option('ca test_server').with(
    'server'  => 'test_server', 
    'key'     => 'ca', 
    'value'   => '/etc/openvpn/test_server/keys/ca.crt'
  )}
  it { should contain_openvpn__option('cert test_server').with(
    'server'  => 'test_server', 
    'key'     => 'cert', 
    'value'   => '/etc/openvpn/test_server/keys/server.crt'
  )}
  it { should contain_openvpn__option('key test_server').with(
    'server'  => 'test_server', 
    'key'     => 'key', 
    'value'   => '/etc/openvpn/test_server/keys/server.key'
  )}
  it { should contain_openvpn__option('dh test_server').with(
    'server'  => 'test_server', 
    'key'     => 'dh', 
    'value'   => '/etc/openvpn/test_server/keys/dh1024.pem'
  )}
  it { should contain_openvpn__option('proto test_server').with(
    'server'  => 'test_server', 
    'key'     => 'proto', 
    'value'   => 'tcp'
  )}
  it { should contain_openvpn__option('comp-lzo test_server').with(
    'server'  => 'test_server', 
    'key'     => 'comp-lzo'
  )}  

  context "when RedHat based machine" do
    let(:facts) { { :osfamily => 'RedHat', :concat_basedir => '/var/lib/puppet/concat' } }
    
    it { should contain_file('/etc/openvpn/test_server/easy-rsa/openssl.cnf').with(
      'ensure'  => 'link',
      'target'  => '/etc/openvpn/test_server/easy-rsa/openssl-1.0.0.cnf'
    )}
    
    it { should contain_exec('copy easy-rsa to openvpn config folder test_server').with(
      'command' => '/bin/cp -r /usr/share/doc/openvpn-2.2.2/easy-rsa/2.0 /etc/openvpn/test_server/easy-rsa'
    )}
    
  end
    
  context "when Debian based machine" do 
    let(:facts) { { :osfamily => 'Debian', :concat_basedir => '/var/lib/puppet/concat' } }

    it { should contain_file('/etc/openvpn/test_server/easy-rsa/openssl.cnf').with(
      'ensure'  => 'link',
      'target'  => '/etc/openvpn/test_server/easy-rsa/openssl-1.0.0.cnf'
    )}
    
    it { should contain_exec('copy easy-rsa to openvpn config folder test_server').with(
      'command' => '/bin/cp -r /usr/share/doc/openvpn/examples/easy-rsa/2.0 /etc/openvpn/test_server/easy-rsa'
    )}

  end
    
end
