# encoding: utf-8

require 'bundler'
Bundler.setup

require 'rom-http'

root = Pathname(__FILE__).dirname

Dir[root.join('support/**/*.rb').to_s].each { |file| require file }
Dir[root.join('shared/**/*.rb').to_s].each { |file| require file }
