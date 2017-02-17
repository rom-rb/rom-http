module ROM
  module HTTP
    # Transformer
    #
    # Used to perform data transformations on behalf of relations
    #
    # @api private
    module Transformer
      extend Transproc::Registry

      import :identity, from: ::Transproc::Coercions
      import :map_array, from: ::Transproc::ArrayTransformations
      import :rename_keys, from: ::Transproc::HashTransformations
      import :deep_merge, from: ::Transproc::HashTransformations
    end
  end
end
