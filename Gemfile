source 'https://rubygems.org'

gemspec

eval_gemfile 'Gemfile.devtools'

group :test do
  gem 'webmock', require: false
  gem 'vcr', require: false
  gem 'simplecov', platforms: :mri
end

group :tools do
  gem 'byebug', platforms: :mri
end
