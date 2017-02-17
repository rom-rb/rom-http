# encoding: utf-8

require 'bundler'
Bundler.setup

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
