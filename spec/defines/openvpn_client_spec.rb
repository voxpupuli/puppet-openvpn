require 'spec_helper'
 
describe 'openvpn::client', :type => :define do
  let(:title) { 'test_client' }
  let(:params) { { 'server' => 'test_server' } }
  let(:facts) { { :fqdn => 'somehost', :concat_basedir => '/var/lib/puppet/concat' } }
  let(:pre_condition) do
    'openvpn::server { "test_server":
      country       => "CO",
      province      => "ST",
      city          => "Some City",
      organization  => "example.org",
      email         => "testemail@example.org"
    }'
  end

  it { should contain_exec('generate certificate for test_client in context of test_server') }

  [ 'test_client', 'test_client/keys'].each do |directory|
    it { should contain_file("/etc/openvpn/test_server/download-configs/#{directory}") }
  end

  [ 'test_client.crt', 'test_client.key', 'ca.crt' ].each do |file|
    it { should contain_file("/etc/openvpn/test_server/download-configs/test_client/keys/#{file}").with(
      'ensure'  => 'link',
      'target'  => "/etc/openvpn/test_server/easy-rsa/keys/#{file}"
    )}
  end
  
  it { should contain_exec('tar the thing test_server with test_client').with(
    'cwd'     => '/etc/openvpn/test_server/download-configs/',
    'command' => '/bin/rm test_client.tar.gz; tar --exclude=\*.conf.d -chzvf test_client.tar.gz test_client'
  ) }

  context "setting the minimum parameters" do
    let(:params) { { 'server' => 'test_server' } }
    let(:facts) { { :fqdn => 'somehost', :concat_basedir => '/var/lib/puppet/concat' } }

    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^client$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^ca\s+keys\/ca\.crt$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^cert\s+keys\/test_client.crt$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^key\s+keys\/test_client\.key$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^dev\s+tun$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^proto\s+tcp$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^remote\s+somehost\s+1194$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^comp-lzo$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^resolv-retry\s+infinite$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^nobind$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^persist-key$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^persist-tun$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^mute-replay-warnings$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^ns\-cert\-type\s+server$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^verb\s+3$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^mute\s+20$/)}
  end

  context "setting all of the parameters" do
    let(:params) { { 
      'server'                => 'test_server',
      'compression'           => 'comp-something',
      'dev'                   => 'tap',
      'mute'                  => 10,
      'mute_replay_warnings'  => false,
      'nobind'                => false,
      'persist_key'           => false,
      'persist_tun'           => false,
      'port'                  => '123',
      'proto'                 => 'udp',
      'remote_host'           => 'somewhere',
      'resolv_retry'          => '2m',
      'verb'                  => '1'
    } }
    let(:facts) { { :fqdn => 'somehost', :concat_basedir => '/var/lib/puppet/concat' } }

    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^client$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^ca\s+keys\/ca\.crt$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^cert\s+keys\/test_client.crt$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^key\s+keys\/test_client\.key$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^dev\s+tap$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^proto\s+udp$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^remote\s+somewhere\s+123$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^comp-something$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^resolv-retry\s+2m$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^verb\s+1$/)}
    it { should contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(/^mute\s+10$/)}
  end

end
