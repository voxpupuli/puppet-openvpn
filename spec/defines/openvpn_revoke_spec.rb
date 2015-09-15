require 'spec_helper'

describe 'openvpn::revoke', :type => :define do
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

  it { should contain_exec('revoke certificate for test_client in context of test_server').with(
    'command' => ". ./vars && ./revoke-full test_client; echo \"exit $?\" | grep -qE '(error 23|exit (0|2))' && touch revoked/test_client"
  )}
end
