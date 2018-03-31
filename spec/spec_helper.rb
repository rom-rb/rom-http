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

root = Pathname(__FILE__).dirname

Dir[root.join('support/**/*.rb').to_s].each { |file| require file }
Dir[root.join('shared/**/*.rb').to_s].each { |file| require file }
