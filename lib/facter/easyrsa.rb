# frozen_string_literal: true

Facter.add(:easyrsa) do
  confine kernel: 'Linux'
  setcode do
    binary = case Facter.value[:os]['family']
             when 'RedHat'
               '/usr/share/easy-rsa/3/easyrsa'
             when 'Debian'
               '/usr/share/easy-rsa/easyrsa'
             when 'FreeBSD'
               '/usr/local/share/easy-rsa/easyrsa'
             when 'Solaris'
               '/opt/local/bin/easyrsa'
             else
               ''
             end

    if File.exist? binary
      data = Facter::Core::Execution.execute("#{binary} help")
      version = '3.0' if data.gsub!(%r{Easy-RSA 3 usage}, '')
    elsif Facter::Util::Resolution.which('easyrsa')
      data = Facter::Core::Execution.execute('easyrsa help')
      version = '3.0' if data.gsub!(%r{Easy-RSA 3 usage}, '')
    end
    version = nil if version.nil?
    version
  end
end
