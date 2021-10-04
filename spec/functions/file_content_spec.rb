# frozen_string_literal: true

require 'spec_helper'

describe 'openvpn::file_content' do
  before do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:read).and_call_original
  end

  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(ArgumentError, %r{'openvpn::file_content' expects 1 argument, got none}) }
  it { is_expected.to run.with_params('one', 'two').and_raise_error(ArgumentError, %r{'openvpn::file_content' expects 1 argument, got 2}) }
  it { is_expected.to run.with_params([]).and_raise_error(ArgumentError, %r{'openvpn::file_content' parameter 'filename' expects a String value, got Array}) }

  context 'when a non-existing file is specified' do
    let(:filename) { '/tmp/doesnotexist' }

    before do
      allow(File).to receive(:exist?).and_return(false)
    end

    it 'filename /tmp/doesnotexist' do
      is_expected.to run.with_params(filename).and_raise_error(RuntimeError, %r{File '#{filename}' does not exists.})

      expect(File).to have_received(:exist?).with(filename)
    end
  end

  context 'when an existing file is specified' do
    let(:filename) { '/tmp/doesexist' }
    let(:content) { 'config' }

    before do
      allow(File).to receive(:exist?).with(filename).and_return(true)
      allow(File).to receive(:read).with(filename).and_return(content)
    end

    it 'filename /tmp/doesexist' do
      is_expected.to run.with_params(filename).and_return(content)

      expect(File).to have_received(:exist?).with(filename)
      expect(File).to have_received(:read).with(filename)
    end
  end

  context 'with UTF8 and double byte characters' do
    let(:filename) { '/tmp/doesexist' }
    let(:content) { 'file_√ạĺűē/竹.rb' }

    before do
      allow(File).to receive(:exist?).with(filename).and_return(true)
      allow(File).to receive(:read).with(filename).and_return(content)
    end

    it 'filename /tmp/doesexist' do
      is_expected.to run.with_params(filename).and_return(content)

      expect(File).to have_received(:exist?).with(filename)
      expect(File).to have_received(:read).with(filename)
    end
  end
end
