require 'rom'
require 'rom/http/gateway'
require 'rom/http/relation'
require 'rom/http/version'

ROM.register_adapter(:http, ROM::HTTP)
