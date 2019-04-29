source 'https://rubygems.org'

gemspec

group :test do
  gem 'rom', git: 'https://github.com/rom-rb/rom', branch: 'master' do
    gem 'rom-core'
    gem 'rom-repository', group: :tools
  end

  gem 'webmock'
  gem 'vcr'
  gem 'simplecov', platforms: :mri
end

group :tools do
  gem 'byebug', platforms: :mri
end
