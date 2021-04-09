# frozen_string_literal: true

require "rom"
require "rom/http/error"
require "rom/http/commands"
require "rom/http/associations"
require "rom/http/gateway"
require "rom/http/relation"
require "rom/http/version"

ROM.register_adapter(:http, ROM::HTTP)
