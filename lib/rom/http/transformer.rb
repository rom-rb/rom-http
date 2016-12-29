module ROM
  module HTTP
    # Transformer
    #
    # Used to perform data transformations on behalf of relations
    #
    # @api private
    class Transformer
      SEPARATOR = '_'.freeze

      extend Transproc::Registry

      import :identity, from: ::Transproc::Coercions
      import :map_array, from: ::Transproc::ArrayTransformations
      import :map_keys, from: ::Transproc::HashTransformations
      import :rename_keys, from: ::Transproc::HashTransformations

      attr_reader :transformer
      private :transformer

      def initialize(transformer = nil)
        @transformer = transformer || self.class[:identity]
      end

      def rename(mapping)
        with(:rename_keys, mapping)
      end

      def prefix(prefix)
        with :map_keys, ->(key) do
          prefixed = [prefix, key].join(SEPARATOR)

          key.is_a?(::Symbol) ? prefixed.to_sym : prefixed
        end
      end

      def call(*args)
        self.class[:map_array, transformer].call(*args)
      end
      alias [] call

      private

      def with(*args)
        self.class.new(transformer >> self.class[*args])
      end
    end
  end
end
