require 'spec_helper'
 
describe 'openvpn::option', :type => :define do

  let(:title) { 'test_param' }
  
  context "when key => 'test_key', server => 'test_server'" do
    let(:params) { { 'key' => 'test_key', 'server' => 'test_server' } }

    it { should contain_concat__fragment('openvpn.test_server..test_param').with(
      'target'  => '/etc/openvpn/test_server.conf',
      'content' => "test_key\n"
    ) }
  end

  context "when key => 'test_key', value => 'test_value', server => 'test_server'" do
    let(:params) { { 'key' => 'test_key', 'value' => 'test_value', 'server' => 'test_server' } }

    it { should contain_concat__fragment('openvpn.test_server..test_param').with(
      'target'  => '/etc/openvpn/test_server.conf',
      'content' => "test_key test_value\n"
    ) }
  end
  
  context "when key => 'test_key', server => 'test_server', client => 'test_client'" do
    let(:params) { { 'key' => 'test_key', 'server' => 'test_server', 'client' => 'test_client' } }

    it { should contain_concat__fragment('openvpn.test_server.test_client.test_param').with(
      'target'  => '/etc/openvpn/test_server/download-configs/test_client/test_client.conf',
      'content' => "test_key\n"
    ) }
  end

  context "when key => 'test_key', server => 'test_server', client => 'test_client', csc => true" do
    let(:params) { { 'key' => 'test_key', 'server' => 'test_server', 'client' => 'test_client', 'csc' => 'true' } }

    it { should contain_concat__fragment('openvpn.test_server.test_client.test_param').with(
      'target'  => '/etc/openvpn/test_server/client-configs/test_client',
      'content' => "test_key\n"
    ) }
  end
end
