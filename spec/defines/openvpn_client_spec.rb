require 'spec_helper'

describe 'openvpn::client', type: :define do
  let(:title) { 'test_client' }
  let(:params) { { 'server' => 'test_server' } }
  let(:facts) do
    {
      fqdn: 'somehost',
      concat_basedir: '/var/lib/puppet/concat',
      osfamily: 'Debian',
      operatingsystem: 'Ubuntu',
      operatingsystemrelease: '12.04'
    }
  end
  let(:pre_condition) do
    'openvpn::server { "test_server":
      country       => "CO",
      province      => "ST",
      city          => "Some City",
      organization  => "example.org",
      email         => "testemail@example.org"
    }'
  end

  it { is_expected.to contain_exec('generate certificate for test_client in context of test_server') }

  ['test_client', 'test_client/keys/test_client'].each do |directory|
    it { is_expected.to contain_file("/etc/openvpn/test_server/download-configs/#{directory}") }
  end

  ['test_client.crt', 'test_client.key', 'ca.crt'].each do |file|
    it {
      is_expected.to contain_file("/etc/openvpn/test_server/download-configs/test_client/keys/test_client/#{file}").with(
        'ensure'  => 'link',
        'target'  => "/etc/openvpn/test_server/easy-rsa/keys/#{file}"
      )
    }
  end

  it {
    is_expected.to contain_exec('tar the thing test_server with test_client').with(
      'cwd'     => '/etc/openvpn/test_server/download-configs/',
      'command' => '/bin/rm test_client.tar.gz; tar --exclude=\*.conf.d -chzvf test_client.tar.gz test_client test_client.tblk'
    )
  }

  context 'setting the minimum parameters' do
    let(:params) { { 'server' => 'test_server' } }

    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^client$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^ca\s+keys/test_client/ca\.crt$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^cert\s+keys/test_client/test_client.crt$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^key\s+keys/test_client/test_client\.key$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^dev\s+tun$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^proto\s+tcp$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^remote\s+somehost\s+1194$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^comp-lzo$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^resolv-retry\s+infinite$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^nobind$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^persist-key$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^persist-tun$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^mute-replay-warnings$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^ns\-cert\-type\s+server$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^verb\s+3$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^mute\s+20$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^auth-retry\s+none$}) }
    it { is_expected.not_to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^tls-client$}) }
    it { is_expected.not_to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^verify-x509-name}) }
    it { is_expected.not_to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^sndbuf}) }
    it { is_expected.not_to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^rcvbuf}) }
    it { is_expected.not_to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^pull}) }
  end

  context 'setting all of the parameters' do
    let(:params) do
      {
        'server'                => 'test_server',
        'compression'           => 'comp-something',
        'dev'                   => 'tap',
        'mute'                  => 10,
        'mute_replay_warnings'  => false,
        'nobind'                => false,
        'persist_key'           => false,
        'persist_tun'           => false,
        'cipher'                => 'AES-256-CBC',
        'tls_cipher'            => 'TLS-DHE-RSA-WITH-AES-256-CBC-SHA',
        'port'                  => '123',
        'proto'                 => 'udp',
        'remote_host'           => %w[somewhere galaxy],
        'resolv_retry'          => '2m',
        'auth_retry'            => 'interact',
        'verb'                  => '1',
        'setenv'                => { 'CLIENT_CERT' => '0' },
        'setenv_safe'           => { 'FORWARD_COMPATIBLE' => '1' },
        'tls_auth'              => true,
        'x509_name'             => 'test_server',
        'sndbuf'                => 393_216,
        'rcvbuf'                => 393_215,
        'readme'                => 'readme text',
        'pull'                  => true,
        'ns_cert_type'          => false,
        'remote_cert_tls'       => true
      }
    end
    let(:facts) do
      {
        fqdn: 'somehost',
        concat_basedir: '/var/lib/puppet/concat',
        osfamily: 'Debian',
        operatingsystem: 'Ubuntu',
        operatingsystemrelease: '12.04'
      }
    end

    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^client$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^ca\s+keys\/test_client\/ca\.crt$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^cert\s+keys\/test_client\/test_client.crt$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^key\s+keys\/test_client\/test_client\.key$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^dev\s+tap$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^proto\s+udp$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^remote\s+somewhere\s+123$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^remote\s+galaxy\s+123$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^comp-something$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^resolv-retry\s+2m$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^verb\s+1$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^mute\s+10$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^auth-retry\s+interact$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^setenv\s+CLIENT_CERT\s+0$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^setenv_safe\s+FORWARD_COMPATIBLE\s+1$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^cipher\s+AES-256-CBC$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^tls-cipher\s+TLS-DHE-RSA-WITH-AES-256-CBC-SHA$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^tls-client$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^verify-x509-name\s+"test_server"\s+name$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^sndbuf\s+393216$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^rcvbuf\s+393215$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/README').with_content(%r{^readme text$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^pull$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^remote-cert-tls\s+server$}) }
  end

  context 'omitting the cipher key' do
    let(:params) { { 'server' => 'test_server' } }

    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^cipher AES-256-CBC$}) }
  end

  context 'should fail if specifying an openvpn::server with extca_enabled=true' do
    let(:params) do
      {
        'server' => 'test_server_extca'
      }
    end

    before do
      pre_condition << '
        openvpn::server { "text_server_extca":
          tls_auth                => true,
          extca_enabled           => true,
          extca_ca_cert_file      => "/etc/ipa/ca.crt",
          extca_ca_crl_file       => "/etc/ipa/ca_crl.pem",
          extca_server_cert_file  => "/etc/pki/tls/certs/localhost.crt",
          extca_server_key_file   => "/etc/pki/tls/private/localhost.key",
          extca_dh_file           => "/etc/ipa/dh.pem",
          extca_tls_auth_key_file => "/etc/openvpn/keys/ta.key",
        }
      '
    end
    it { expect { is_expected.to contain_file('test') }.to raise_error(Puppet::Error) }
  end

  context 'when using shared ca' do
    let(:params) do
      {
        'server' => 'test_server',
        'shared_ca' => 'my_already_existing_ca'
      }
    end

    before do
      pre_condition << '
        openvpn::server { "my_already_existing_ca":
          country       => "CO",
          province      => "ST",
          city          => "Some City",
          organization  => "example.org",
          email         => "testemail@example.org"
        }
      '
    end

    it { is_expected.to contain_openvpn__ca('my_already_existing_ca') }

    it { is_expected.to contain_exec('generate certificate for test_client in context of my_already_existing_ca') }
    ['test_client.crt', 'test_client.key', 'ca.crt'].each do |file|
      it {
        is_expected.to contain_file("/etc/openvpn/test_server/download-configs/test_client/keys/test_client/#{file}").with(
          'ensure'  => 'link',
          'target'  => "/etc/openvpn/my_already_existing_ca/easy-rsa/keys/#{file}"
        )
      }
    end

    # Check that certificate files point to the provided CA
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^client$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^ca\s+keys/test_client/ca\.crt$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^cert\s+keys/test_client/test_client.crt$}) }
    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^key\s+keys/test_client/test_client\.key$}) }
  end

  context 'when using not existed shared ca' do
    let(:params) do
      {
        'server' => 'test_server',
        'shared_ca' => 'my_already_existing_ca'
      }
    end

    it { expect { is_expected.to contain_file('test') }.to raise_error(Puppet::Error) }
  end

  context 'custom options' do
    let(:params) do
      {
        'server'         => 'test_server',
        'custom_options' => { 'this' => 'that' }
      }
    end

    it { is_expected.to contain_file('/etc/openvpn/test_server/download-configs/test_client/test_client.conf').with_content(%r{^this that$}) }
  end
end
