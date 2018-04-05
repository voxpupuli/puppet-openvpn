Facter.add(:easyrsa) do
  confine :kernel => 'Linux'
  setcode do
    version = ''
    binaryv2 = ''
    binaryv3 = ''
    operatingsystem = Facter.value(:operatingsystem)
    operatingsystemrelease = Facter.value(:operatingsystemrelease)

    case operatingsystem
    when /RedHat|CentOS/
      binaryv2 = '/usr/share/easy-rsa/2.0/pkitool'
      binaryv3 = '/usr/share/easy-rsa/3/easyrsa'
    when /Ubuntu|Debian/
      case operatingsystemrelease
      when /8|9|16.04|18.04/
        binaryv2 = '/usr/share/easy-rsa/pkitool'
        binaryv3 = '/usr/share/easy-rsa/easyrsa'
      else
        binaryv2 = '/usr/share/doc/openvpn/examples/easy-rsa/2.0/pkitool'
        binaryv3 = '/usr/share/doc/openvpn/examples/easy-rsa/3.0/easyrsa'
      end
    when /Archlinux/
      binaryv2 = '/usr/share/easy-rsa/2.0/pkitool'
      binaryv3 = '/usr/share/easy-rsa/3/easyrsa'
    when /Amazon/
      binaryv2 = '/usr/share/easy-rsa/2.0/pkitool'
      binaryv3 = '/usr/share/easy-rsa/3/easyrsa'
    when /FreeBSD/
      binaryv2 = '/usr/local/share/easy-rsa/pkitool'
      binaryv3 = '/usr/local/share/easy-rsa/easyrsa'
    end

    if File.exist? binaryv2
      Open3.popen2("#{binaryv2} --help") do |stdin, stdout, status_thread|
        stdout.each_line do |line|
          if line.include?('pkitool 2.0')
            version = '2.0'
            break
          end
        end
      end
      version
    elsif File.exist? binaryv3
      Open3.popen2("#{binaryv3} --help") do |stdin, stdout, status_thread|
        stdout.each_line do |line|
          if line.include?('Easy-RSA 3 usage and overview')
            version = '3.0'
            break
          end
        end
      end
      version
    end
  end
end

