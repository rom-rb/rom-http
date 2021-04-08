# frozen_string_literal: true

require "rom/types"

module ROM
  module HTTP
    module Types
      include ROM::Types

      Path = Coercible::String.constructor { |s| s.sub(%r{\A/}, "") }
    end
  end
end
