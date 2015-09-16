module ROM
  module HTTP
    module Support
      class Transformations
        extend Transproc::Registry

        uses :map_array, from: ::Transproc::ArrayTransformations
        uses :accept_keys, from: ::Transproc::HashTransformations
        import :identity, from: ::Transproc::Coercions, as: :noop

        def self.apply_projections(value, projections)
          t(:map_array, t(:accept_keys, projections)).call(value)
        end
      end
    end
  end
end
