source 'https://rubygems.org'

gemspec

group :test do
  gem 'byebug', platforms: :mri
  gem 'rom', github: 'rom-rb/rom', branch: 'master'
  gem 'rspec', '~> 3.1'
  gem 'codeclimate-test-reporter', require: false
end

group :tools do
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'rubocop', '~> 0.28'
end
