source 'https://rubygems.org'

gemspec

eval_gemfile 'Gemfile.devtools'

group :test do
  gem 'rom', git: 'https://github.com/rom-rb/rom', branch: 'main' do
    gem 'rom-core'
    gem 'rom-repository', group: :tools
  end

  gem 'webmock', require: false
  gem 'vcr', require: false
  gem 'simplecov', platforms: :mri
end

group :tools do
  gem 'byebug', platforms: :mri
end
