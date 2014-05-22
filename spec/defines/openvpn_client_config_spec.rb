require 'spec_helper'

describe 'openvpn::client::config', :type => :define do
  let(:title) { 'test_client' }
  let(:params) { {
    'remote_host' => 'somehost',
    'path' => '/etc/openvpn/test_client.conf',
  } }
  let(:facts) { { :osfamily => 'Debian', :lsbdistid => 'Debian', :concat_basedir => '/var/lib/puppet/concat' } }

  it { should contain_file('/etc/openvpn/test_client.conf').that_requires('Class[openvpn::install]') }
  it { should contain_file('/etc/openvpn/test_client.conf').that_notifies('Class[openvpn::service]') }

  params_hash = { 'path' => '/etc/openvpn/test_client.conf' }

  it_has_behavior "creates client config file", "/etc/openvpn/test_client.conf", params_hash

end
