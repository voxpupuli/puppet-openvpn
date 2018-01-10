require 'spec_helper'
require_relative '../../lib/facter/openvpn'

describe Openvpn do
  describe '.etc_path' do
    subject(:path) { described_class.etc_path }

    before do
      Facter.fact(:osfamily).stubs(:value).returns(osfamily)
    end

    after { Facter.clear }

    context 'on FreeBSD' do
      let(:osfamily) { 'FreeBSD' }

      it { is_expected.to eq('/usr/local/etc/openvpn') }
    end
    context 'on Debian' do
      let(:osfamily) { 'Debian' }

      it { is_expected.to eq('/etc/openvpn') }
    end
    context 'on RedHat' do
      let(:osfamily) { 'RedHat' }

      it { is_expected.to eq('/etc/openvpn') }
    end
    context 'on Archlinux' do
      let(:osfamily) { 'Archlinux' }

      it { is_expected.to eq('/etc/openvpn') }
    end
    context 'on Linux' do
      let(:osfamily) { 'Linux' }

      it { is_expected.to eq('/etc/openvpn') }
    end
    context 'on Other' do
      let(:osfamily) { 'Other' }

      it { is_expected.to eq('') }
    end
  end

  describe '.client_certs' do
    subject(:path) { described_class.client_certs }

    before do
      Facter.fact(:osfamily).stubs(:value).returns(osfamily)
    end

    after { Facter.clear }

    context 'with Openvpn installed' do
      let(:osfamily) { 'Linux' }

      before do
        allow(Dir).to receive(:entries).and_call_original
        allow(Dir).to receive(:entries).with('/etc/openvpn').and_return(%w[. .. test-server])
        allow(Dir).to receive(:entries).with('/etc/openvpn/test-server').and_return(%w[. .. download-configs])
        allow(Dir).to receive(:entries).with('/etc/openvpn/test-server/download-configs').and_return(%w[. .. test2 client3 other4])
        allow(File).to receive(:directory?).and_call_original
        allow(File).to receive(:directory?).with('/etc/openvpn').and_return(true)
        allow(File).to receive(:directory?).with('/etc/openvpn/test-server').and_return(true)
        allow(File).to receive(:directory?).with('/etc/openvpn/test-server/download-configs').and_return(true)
        allow(File).to receive(:directory?).with('/etc/openvpn/test-server/download-configs/test2').and_return(true)
        allow(File).to receive(:open).with('/etc/openvpn/test-server/download-configs/test2/test2.conf', 'r').and_return(StringIO.new('conf'))
        allow(File).to receive(:open).with('/etc/openvpn/test-server/download-configs/test2/keys/test2/ca.crt', 'r').and_return(StringIO.new('ca'))
        allow(File).to receive(:open).with('/etc/openvpn/test-server/download-configs/test2/keys/test2/test2.crt', 'r').and_return(StringIO.new('crt'))
        allow(File).to receive(:open).with('/etc/openvpn/test-server/download-configs/test2/keys/test2/test2.key', 'r').and_return(StringIO.new('key'))
      end
      it { is_expected.to eq('test-server' => { 'test2' => { 'conf' => 'conf', 'ca' => 'ca', 'crt' => 'crt', 'key' => 'key' } }) }

      context 'with tsl_auth enabled' do
        before do
          allow(File).to receive(:exist?).with('/etc/openvpn/test-server/download-configs/test2/keys/test2/ta.key').and_return(true)
          allow(File).to receive(:open).with('/etc/openvpn/test-server/download-configs/test2/keys/test2/ta.key', 'r').and_return(StringIO.new('ta'))
        end

        it { is_expected.to eq('test-server' => { 'test2' => { 'conf' => 'conf', 'ca' => 'ca', 'crt' => 'crt', 'key' => 'key', 'ta' => 'ta' } }) }
      end
    end
  end

  describe 'openvpn fact' do
    subject(:fact) { Facter.fact('openvpn').value }

    before do
      # Ensure we're populating Facter's internal collection with our Fact
      described_class.add_facts
    end

    # A regular ol' RSpec example
    it { is_expected.to eq({}) }

    after do
      # Make sure we're clearing out Facter every time
      Facter.clear
      Facter.clear_messages
    end
  end
end
