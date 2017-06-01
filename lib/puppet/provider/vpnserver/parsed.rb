require 'puppet/provider/parsedfile'

Puppet::Type.type(:vpnserver).provide(
  :parsed, 
  :parent => Puppet::Provider::ParsedFile, 
  :default_target => '/etc/puppet/zh/keys/server.crt', 
  :filetype => :flat
) do
  desc "The shells provider that uses the ParsedFile class"

  text_line :comment, :match => /^#/;
  text_line :blank, :match => /^\s*$/;

  record_line :parsed, :fields => %w{crt}
end
