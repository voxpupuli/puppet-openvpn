# frozen_string_literal: true

Facter.add(:easyrsa) do
  confine kernel: 'Linux'
  setcode do
    binaryv3 = ''
    operatingsystem = Facter.value(:operatingsystem)
    operatingsystemrelease = Facter.value(:operatingsystemrelease)

    case operatingsystem
    when %r{RedHat|CentOS|Amazon|Rocky|AlmaLinux|OracleLinux}
      binaryv3 = '/usr/share/easy-rsa/3/easyrsa'
    when %r{Ubuntu|Debian}
      binaryv3 = case operatingsystemrelease
                 when %r{|11|12|22.04|24.04}
                   '/usr/share/easy-rsa/easyrsa'
                 else
                   '/usr/share/doc/openvpn/examples/easy-rsa/3.0/easyrsa'
                 end
    when %r{FreeBSD}
      binaryv3 = '/usr/local/share/easy-rsa/easyrsa'
    when %r{Solaris}
      binaryv3 = '/opt/local/bin/easyrsa'
    end

    if File.exist? binaryv3
      data = Facter::Core::Execution.execute("#{binaryv3} help")
      version = '3.0' if data.gsub!(%r{Easy-RSA 3 usage}, '')
    elsif Facter::Util::Resolution.which('easyrsa')
      data = Facter::Core::Execution.execute('easyrsa help')
      version = '3.0' if data.gsub!(%r{Easy-RSA 3 usage}, '')
    end
    version = nil if version.nil?
    version
  end
end
