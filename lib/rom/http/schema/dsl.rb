# frozen_string_literal: true

require 'rom/schema/dsl'

module ROM
  module HTTP
    class Schema < ROM::Schema
      class DSL < ROM::Schema::DSL
      end
    end
  end
end
