require 'spec_helper'

describe 'openvpn::client_specific_config', :type => :define do
  let(:title) { 'test_client' }
  let(:params) { { 'server' => 'test_server' } }
  let(:facts) { {
    :fqdn => 'somehost',
    :concat_basedir => '/var/lib/puppet/concat',
    :osfamily => 'Debian',
    :operatingsystem => 'Ubuntu',
    :operatingsystemrelease => '12.04',
  } }
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
      {:server           => 'test_server',
       :iroute           => ['10.0.1.0 255.255.255.0'],
       :iroute_ipv6      => ['2001:db8:1234::/64'],
       :ifconfig         => '10.10.10.2 255.255.255.0',
       :route            => ['10.200.100.0 255.255.255.0 10.10.10.1'],
       :dhcp_options     => ['DNS 8.8.8.8'],
       :redirect_gateway => true}
    end

    it { should contain_file('/etc/openvpn/test_server/client-configs/test_client').with_content(/^iroute 10.0.1.0 255.255.255.0$/) }
    it { should contain_file('/etc/openvpn/test_server/client-configs/test_client').with_content(/^iroute-ipv6 2001\:db8\:1234\:\:\/64$/) }
    it { should contain_file('/etc/openvpn/test_server/client-configs/test_client').with_content(/^ifconfig-push 10.10.10.2 255.255.255.0$/) }
    it { should contain_file('/etc/openvpn/test_server/client-configs/test_client').with_content(/^push dhcp-option DNS 8.8.8.8$/) }
    it { should contain_file('/etc/openvpn/test_server/client-configs/test_client').with_content(/^push redirect-gateway def1$/) }
    it { should contain_file('/etc/openvpn/test_server/client-configs/test_client').with_content(/^push "route 10.200.100.0 255.255.255.0 10.10.10.1"$/) }
  end
end
