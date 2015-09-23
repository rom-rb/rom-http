source 'https://rubygems.org'

gemspec

gem 'dry-data', github: 'dryrb/dry-data'

group :test do
  gem 'rom', github: 'rom-rb/rom', branch: 'master'
  gem 'faraday'
  gem 'inflecto'
end

group :tools do
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'rubocop', '~> 0.28'

  platform :mri do
    gem 'mutant', '>= 0.8.0', github: 'mbj/mutant', branch: 'master'
    gem 'mutant-rspec'
  end
end
