require 'dry/core/cache'
require 'rom/initializer'
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

      option :transformer, reader: true, default: proc { ::ROM::HTTP::Transformer }

      forward :with_headers, :add_header, :with_options,
              :with_base_path, :with_path, :append_path,
              :with_request_method, :with_params, :add_params

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

      def with_transformation
        tuples = yield

        transformed = with_schema_proc do |proc|
          transformer_proc[Array([tuples]).flatten(1).map(&proc.method(:call))]
        end

        tuples.kind_of?(Array) ? transformed : transformed.first
      end

      def with_schema_proc
        schema_proc = fetch_or_store(schema) do
          Types::Coercible::Hash.schema(schema.to_h)
        end

        yield(schema_proc)
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
