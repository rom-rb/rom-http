source "https://rubygems.org"

gemspec

eval_gemfile "Gemfile.devtools"

group :test do
  gem "rspec"
  gem "rspec-its"
  gem "vcr", require: false
  gem "webmock", require: false
end

group :tools do
  gem "byebug", platforms: :mri
end
