require 'spec_helper'

describe 'openvpn::client_specific_config', :type => :define do
  let(:title) { 'test_client' }
  let(:params) { { 'server' => 'test_server' } }
  let(:facts) { { :fqdn => 'somehost', :concat_basedir => '/var/lib/puppet/concat' } }
  let(:pre_condition) do
    [
      'openvpn::server { "test_server":
        country       => "CO",
        province      => "ST",
        city          => "Some City",
        organization  => "example.org",
        email         => "testemail@example.org"
      }',
      'openvpn::client { "test_client":
        server => "test_server"
      }'
    ].join
  end

  it { should contain_file('/etc/openvpn/test_server/client-configs/test_client') }

  describe "setting no paramter at all" do
    it { should contain_file('/etc/openvpn/test_server/client-configs/test_client').with_content(/\A\n\z/) }
  end

  describe "setting all parameters" do
    let(:params) do
      {:server       => 'test_server',
       :iroute       => ['10.0.1.0 255.255.255.0'],
       :ifconfig     => '10.10.10.2 255.255.255.0',
       :dhcp_options => ['DNS 8.8.8.8']}
    end

    it { should contain_file('/etc/openvpn/test_server/client-configs/test_client').with_content(/^iroute 10.0.1.0 255.255.255.0$/) }
    it { should contain_file('/etc/openvpn/test_server/client-configs/test_client').with_content(/^ifconfig-push 10.10.10.2 255.255.255.0$/) }
    it { should contain_file('/etc/openvpn/test_server/client-configs/test_client').with_content(/^push dhcp-option DNS 8.8.8.8$/) }
  end
end
