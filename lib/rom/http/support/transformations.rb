module ROM
  module HTTP
    module Support
      class Transformations
        extend Transproc::Registry
        import :accept_keys, from: ::Transproc::HashTransformations, as: :project
        import :identity, from: ::Transproc::Coercions
      end
    end
  end
end
