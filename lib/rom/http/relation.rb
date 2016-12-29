require 'dry/core/cache'
require 'rom/plugins/relation/key_inference'
require 'rom/http/transformer'

module ROM
  module HTTP
    # HTTP-specific relation extensions
    #
    class Relation < ROM::Relation
      extend Dry::Core::Cache
      include Enumerable

      adapter :http

      use :key_inference

      option :transformer, reader: true, default: proc { ::ROM::HTTP::Transformer.new }

      forward :with_request_method, :with_path, :append_path, :with_options,
              :with_params, :clear_params


      def initialize(*)
        super

        raise(
          SchemaNotDefinedError,
          "You must define a schema for #{self.class.register_as} relation"
        ) unless schema?
      end

      def project(*names)
        with(schema: schema.project(*names.flatten))
      end

      def exclude(*names)
        with(schema: schema.exclude(*names.flatten))
      end

      def rename(mapping)
        with(
          schema: schema.rename(mapping),
          transformer: transformer.rename(mapping)
        )
      end

      def prefix(prefix)
        with(
          schema: schema.prefix(prefix),
          transformer: transformer.prefix(prefix)
        )
      end

      def wrap(prefix = dataset.name)
        with(
          schema: schema.wrap(prefix),
          transformer: transformer.prefix(prefix)
        )
      end

      def to_a
        with_schema_proc do |proc|
          transformer[super.map { |data| proc[data] }]
        end
      end

      # @see Dataset#insert
      def insert(*args)
        dataset.insert(*args)
      end
      alias_method :<<, :insert

      # @see Dataset#update
      def update(*args)
        dataset.update(*args)
      end

      # @see Dataset#delete
      def delete
        dataset.delete
      end

      private

      def with_schema_proc(&block)
        schema_proc = fetch_or_store(schema) do
          Types::Coercible::Hash.schema(schema.to_h)
        end

        block.call(schema_proc)
      end
    end
  end
end
