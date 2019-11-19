Facter.add(:easyrsa) do
  confine kernel: 'Linux'
  setcode do
    binaryv2 = ''
    binaryv3 = ''
    operatingsystem = Facter.value(:operatingsystem)
    operatingsystemrelease = Facter.value(:operatingsystemrelease)

    case operatingsystem
    when %r{RedHat|CentOS}
      binaryv2 = '/usr/share/easy-rsa/2.0/pkitool'
      binaryv3 = '/usr/share/easy-rsa/3/easyrsa'
    when %r{Ubuntu|Debian}
      case operatingsystemrelease
      when %r{8|9|10|16.04|18.04}
        binaryv2 = '/usr/share/easy-rsa/pkitool'
        binaryv3 = '/usr/share/easy-rsa/easyrsa'
      else
        binaryv2 = '/usr/share/doc/openvpn/examples/easy-rsa/2.0/pkitool'
        binaryv3 = '/usr/share/doc/openvpn/examples/easy-rsa/3.0/easyrsa'
      end
    when %r{Amazon}
      binaryv2 = '/usr/share/easy-rsa/2.0/pkitool'
      binaryv3 = '/usr/share/easy-rsa/3/easyrsa'
    when %r{FreeBSD}
      binaryv2 = '/usr/local/share/easy-rsa/pkitool'
      binaryv3 = '/usr/local/share/easy-rsa/easyrsa'
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
    if !version.nil?
    else
      version = nil
    end
    version
  end
end
