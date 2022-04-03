source 'https://rubygems.org'

gemspec

eval_gemfile 'Gemfile.devtools'

group :test do
  gem 'rspec'
  gem 'rspec-its'
  gem 'webmock', require: false
  gem 'vcr', require: false
end

group :tools do
  gem 'byebug', platforms: :mri
end
