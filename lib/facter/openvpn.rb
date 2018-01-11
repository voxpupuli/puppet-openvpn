require 'facter'

module Openvpn
  def self.etc_path
    case Facter.value(:osfamily)
    when 'FreeBSD'
      '/usr/local/etc/openvpn'
    when 'RedHat'
      '/etc/openvpn'
    when 'Debian'
      '/etc/openvpn'
    when 'Archlinux'
      '/etc/openvpn'
    when 'Linux'
      '/etc/openvpn'
    else
      ''
    end
  end

  def self.client_certs
    path = etc_path
    clients = {}
    if File.directory?(path)
      Dir.entries(path).each do |server|
        next unless File.directory?("#{path}/#{server}/download-configs")
        clients[server.to_s] = {}

        Dir.entries("#{path}/#{server}/download-configs").each do |client|
          next unless File.directory?("#{path}/#{server}/download-configs/#{client}") && client !~ %r{^\.\.?$} && client !~ %r{\.tblk$}

          clients[server.to_s][client.to_s] = {}
          clients[server.to_s][client.to_s]['conf'] = File.open("#{path}/#{server}/download-configs/#{client}/#{client}.conf", 'r').read
          clients[server.to_s][client.to_s]['ca'] = File.open("#{path}/#{server}/download-configs/#{client}/keys/#{client}/ca.crt", 'r').read
          clients[server.to_s][client.to_s]['crt'] = File.open("#{path}/#{server}/download-configs/#{client}/keys/#{client}/#{client}.crt", 'r').read
          clients[server.to_s][client.to_s]['key'] = File.open("#{path}/#{server}/download-configs/#{client}/keys/#{client}/#{client}.key", 'r').read
          if File.exist?("#{path}/#{server}/download-configs/#{client}/keys/#{client}/ta.key")
            clients[server.to_s][client.to_s]['ta'] = File.open("#{path}/#{server}/download-configs/#{client}/keys/#{client}/ta.key", 'r').read
          end
        end
      end
    end
    clients
  end

  # Method to call the Facter DSL and dynamically add facts at runtime.
  #
  # This method is necessary to add reasonable RSpec coverage for the custom
  # fact
  #
  # @return [NilClass]
  def self.add_facts
    certs = client_certs
    Facter.add('openvpn') do
      setcode do
        certs
      end
    end
  end
end

Openvpn.add_facts
