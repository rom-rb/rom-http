source 'https://rubygems.org'

gemspec

gem 'rom-repository', '~> 2.0'

group :test do
  gem 'rom', '~> 4.0'
  gem 'faraday'
  gem 'inflecto'
end

group :tools do
  gem 'byebug'
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-rubocop'
  gem 'rubocop', '~> 0.28'

  platform :mri do
    gem 'mutant', '>= 0.8.0', github: 'mbj/mutant', branch: 'master'
    gem 'mutant-rspec'
  end
end
