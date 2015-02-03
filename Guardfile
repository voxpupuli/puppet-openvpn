notification :off

guard 'rake', :task => 'test' do
  watch(%r{^manifests\/(.+)\.pp$})
  watch(%r{^spec\/classes\/(.+)\.rb$})
  watch(%r{^spec\/defines\/(.+)\.rb$})
end
