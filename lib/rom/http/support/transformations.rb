module ROM
  module HTTP
    module Support
      class Transformations
        extend Transproc::Registry

        import :map_array, from: ::Transproc::ArrayTransformations
        import :accept_keys, from: ::Transproc::HashTransformations
      end
    end
  end
end
