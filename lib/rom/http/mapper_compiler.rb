# frozen_string_literal: true

require "rom/mapper_compiler"

module ROM
  module HTTP
    class MapperCompiler < ROM::MapperCompiler
      mapper_options(reject_keys: true)
    end
  end
end
