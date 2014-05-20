require 'spec_helper'

describe 'openvpn::client', :type => :define do
  let(:title) { 'test_client' }
  let(:params) { { 'server' => 'test_server' } }
  let(:facts) { {
    :fqdn           => 'somehost',
    :concat_basedir => '/var/lib/puppet/concat',
    :osfamily       => 'Debian',
    :lsbdistid      => 'Ubuntu',
    :lsbdistrelease => '12.04',
  } }
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

  params_hash = { 'server' => 'test_server' }

  it_has_behavior "creates client config file", "/etc/openvpn/test_server/download-configs/test_client/test_client.conf", params_hash

end
