# A function that return a file content at apply time
Puppet::Functions.create_function(:'openvpn::file_content') do
  # @param filename Path of file to cat
  # @return [String] Returns the file content
  dispatch :file_content do
    param 'String', :filename
    return_type 'String'
  end

  def file_content(filename)
    if File.exist?(filename)
      File.read(filename)
    else
      return '' if Puppet.settings[:noop]

      raise "File '#{filename}' does not exists."
    end
  end
end
