shared_examples "creates client config file" do |file, params_hash|
  context "with default parameters" do
    it { should contain_file(file).with_content(/^client$/)}
    it { should contain_file(file).with_content(/^ca\s+keys\/ca\.crt$/)}
    it { should contain_file(file).with_content(/^cert\s+keys\/test_client.crt$/)}
    it { should contain_file(file).with_content(/^key\s+keys\/test_client\.key$/)}
    it { should contain_file(file).with_content(/^dev\s+tun$/)}
    it { should contain_file(file).with_content(/^proto\s+tcp$/)}
    it { should contain_file(file).with_content(/^remote\s+somehost\s+1194$/)}
    it { should contain_file(file).with_content(/^comp-lzo$/)}
    it { should contain_file(file).with_content(/^resolv-retry\s+infinite$/)}
    it { should contain_file(file).with_content(/^nobind$/)}
    it { should contain_file(file).with_content(/^persist-key$/)}
    it { should contain_file(file).with_content(/^persist-tun$/)}
    it { should contain_file(file).with_content(/^mute-replay-warnings$/)}
    it { should contain_file(file).with_content(/^ns\-cert\-type\s+server$/)}
    it { should contain_file(file).with_content(/^verb\s+3$/)}
    it { should contain_file(file).with_content(/^mute\s+20$/)}
  end

  context "with a shared secret" do
    let(:params) { {
      'remote_host'           => 'somehost',
      'shared_secret'         => 'sharedkey.key',
    }.merge(params_hash) }
    it { should contain_file(file).with_content(/^client$/)}
    it { should_not contain_file(file).with_content(/^ca\s/)}
    it { should_not contain_file(file).with_content(/^cert\s/)}
    it { should_not contain_file(file).with_content(/^key\s/)}
    it { should contain_file(file).with_content(/^secret\s+sharedkey\.key$/)}
  end

  context "with explicitly declared parameters" do
    let(:params) { {
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
    }.merge(params_hash) }
    it { should contain_file(file).with_content(/^client$/)}
    it { should contain_file(file).with_content(/^ca\s+keys\/ca\.crt$/)}
    it { should contain_file(file).with_content(/^cert\s+keys\/test_client.crt$/)}
    it { should contain_file(file).with_content(/^key\s+keys\/test_client\.key$/)}
    it { should contain_file(file).with_content(/^dev\s+tap$/)}
    it { should contain_file(file).with_content(/^proto\s+udp$/)}
    it { should contain_file(file).with_content(/^remote\s+somewhere\s+123$/)}
    it { should contain_file(file).with_content(/^comp-something$/)}
    it { should contain_file(file).with_content(/^resolv-retry\s+2m$/)}
    it { should contain_file(file).with_content(/^verb\s+1$/)}
    it { should contain_file(file).with_content(/^mute\s+10$/)}
  end
end
