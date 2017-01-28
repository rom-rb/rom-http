require 'dry/core/cache'
require 'rom/initializer'
require 'rom/plugins/relation/key_inference'
require 'rom/http/transformer'

module ROM
  module HTTP
    # HTTP-specific relation extensions
    #
    class Relation < ROM::Relation
      extend Dry::Core::Cache
      extend ::ROM::Initializer
      include Enumerable

      adapter :http

      use :key_inference

      option :transformer, reader: true, default: proc { ::ROM::HTTP::Transformer }

      defines :base_path

      forward :with_request_method, :with_path, :append_path, :with_options,
              :with_params, :clear_params


      class << self
        def dataset_options
          @dataset_options ||= {
            base_path: base_path
          }
        end
      end

      def initialize(*)
        super

        raise(
          SchemaNotDefinedError,
          "You must define a schema for #{self.class.register_as} relation"
        ) unless schema?
      end

      def primary_key
        attribute = schema.find(&:primary_key?)

        if attribute
          attribute.alias || attribute.name
        else
          :id
        end
      end

      def project(*names)
        with(schema: schema.project(*names.flatten))
      end

      def exclude(*names)
        with(schema: schema.exclude(*names.flatten))
      end

      def rename(mapping)
        with(schema: schema.rename(mapping))
      end

      def prefix(prefix)
        with(schema: schema.prefix(prefix))
      end

      def wrap(prefix = dataset.name)
        with(schema: schema.wrap(prefix))
      end

      def to_a
        with_transformation { super }
      end

      # @see Dataset#insert
      def insert(*args)
        with_transformation { dataset.insert(*args) }
      end
      alias_method :<<, :insert

      # @see Dataset#update
      def update(*args)
        with_transformation { dataset.update(*args) }
      end

      # @see Dataset#delete
      def delete
        dataset.delete
      end

      private

      def with_transformation(&block)
        tuples = block.call

        transformed = with_schema_proc do |proc|
          transformer_proc[Array([tuples]).flatten(1).map(&proc.method(:call))]
        end

        tuples.kind_of?(Array) ? transformed : transformed.first
      end

      def with_schema_proc(&block)
        schema_proc = fetch_or_store(schema) do
          Types::Coercible::Hash.schema(schema.to_h)
        end

        block.call(schema_proc)
      end

      def transformer_proc
        if mapped?
          transformer[:map_array, transformer[:rename_keys, mapping]]
        else
          transformer[:identity]
        end
      end

      def mapped?
        mapping.any?
      end

      def mapping
        schema.each_with_object({}) do |attr, mapping|
          mapping[attr.name] = attr.alias if attr.alias
        end
      end
    end
  end
end
