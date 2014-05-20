require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

require 'rspec-puppet'

# Include shared examples in spec/support/*
Dir["./spec/support/**/*.rb"].each {|f| require f}

# This will make stdlib functions available when test examples will run
$:.unshift File.join(File.dirname(__FILE__),  'fixtures', 'modules', 'stdlib', 'lib')

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.module_path = File.join(fixture_path, 'modules')
  c.manifest_dir = File.join(fixture_path, 'manifests')
  c.alias_it_should_behave_like_to :it_has_behavior, 'has behavior:'
end
