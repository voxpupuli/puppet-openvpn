# frozen_string_literal: true

Facter.add(:easyrsa) do
  confine kernel: 'Linux'
  setcode do
    binaryv2 = ''
    binaryv3 = ''
    operatingsystem = Facter.value(:operatingsystem)
    operatingsystemrelease = Facter.value(:operatingsystemrelease)

    case operatingsystem
    when %r{RedHat|CentOS|Amazon}
      binaryv2 = '/usr/share/easy-rsa/2.0/pkitool'
      binaryv3 = '/usr/share/easy-rsa/3/easyrsa'
    when %r{Ubuntu|Debian}
      case operatingsystemrelease
      when %r{11|12|18.04|20.04|22.04}
        binaryv2 = '/usr/share/easy-rsa/pkitool'
        binaryv3 = '/usr/share/easy-rsa/easyrsa'
      else
        binaryv2 = '/usr/share/doc/openvpn/examples/easy-rsa/2.0/pkitool'
        binaryv3 = '/usr/share/doc/openvpn/examples/easy-rsa/3.0/easyrsa'
      end
    when %r{FreeBSD}
      binaryv2 = '/usr/local/share/easy-rsa/pkitool'
      binaryv3 = '/usr/local/share/easy-rsa/easyrsa'
    when %r{Solaris}
      binaryv3 = '/opt/local/bin/easyrsa'
    end

    if File.exist? binaryv3
      data = Facter::Core::Execution.execute("#{binaryv3} --help")
      version = '3.0' if data.gsub!(%r{Easy-RSA 3 usage}, '')
    elsif File.exist? binaryv2
      data = Facter::Core::Execution.execute("#{binaryv2} --help")
      version = '2.0' if data.gsub!(%r{pkitool 2.0}, '')
    elsif Facter::Util::Resolution.which('pkitool')
      data = Facter::Core::Execution.execute('pkitool --help')
      version = '2.0' if data.gsub!(%r{pkitool 2.0}, '')
    elsif Facter::Util::Resolution.which('easyrsa')
      data = Facter::Core::Execution.execute('easyrsa --help')
      version = '3.0' if data.gsub!(%r{Easy-RSA 3 usage}, '')
    end
    version = nil if version.nil?
    version
  end
end
