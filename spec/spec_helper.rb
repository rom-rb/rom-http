# encoding: utf-8

require 'pathname'

SPEC_ROOT = root = Pathname(__FILE__).dirname

if RUBY_ENGINE == 'ruby' && ENV['COVERAGE'] == 'true'
  require 'yaml'
  rubies = YAML.load(File.read(SPEC_ROOT.join('../.travis.yml')))['rvm']
  latest_mri = rubies.select { |v| v =~ /\A\d+\.\d+.\d+\z/ }.max

  if RUBY_VERSION == latest_mri
    require 'simplecov'

    SimpleCov.start do
      add_filter '/spec/'
    end
  end
end

require 'rom-http'
require 'rspec/its'
require 'dry/configurable/test_interface'

ROM::HTTP::Dataset.enable_test_interface

begin
require 'byebug'
rescue LoadError; end

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "#{SPEC_ROOT}/fixtures/vcr_cassettes"
  config.hook_into :webmock
end

Dir[root.join('support/**/*.rb').to_s].each { |file| require file }
Dir[root.join('shared/**/*.rb').to_s].each { |file| require file }

# Namespace holding all objects created during specs
module Test
  def self.remove_constants
    constants.each(&method(:remove_const))
  end
end

RSpec.configure do |config|
  config.after do
    Test.remove_constants
  end

  config.disable_monkey_patching!
  config.warnings = true
end
