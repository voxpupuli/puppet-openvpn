source 'https://rubygems.org'

group :unit_tests do
  gem 'rake',                    :require => false
  gem 'rspec-puppet',            :require => false, :git => 'https://github.com/rodjek/rspec-puppet.git', :tag => 'v2.0.0'
  gem 'puppetlabs_spec_helper',  :require => false
  gem 'puppet-lint', '1.0.1',    :require => false
  gem 'puppet-syntax',           :require => false
  gem 'metadata-json-lint',      :require => false
end

group :development do
  gem 'simplecov',   :require => false
  gem 'guard-rake',  :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
  if puppetversion == "~> 2.7.0"
    gem 'hiera-puppet', :require => false
    gem 'hiera', :require => false
  end
else
  gem 'puppet', :require => false
end
