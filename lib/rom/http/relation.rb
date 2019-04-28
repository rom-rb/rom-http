# frozen_string_literal: true

require 'rom/initializer'

require 'rom/http/types'
require 'rom/http/attribute'
require 'rom/http/schema'
require 'rom/http/schema/dsl'

module ROM
  module HTTP
    # HTTP-specific relation extensions
    #
    class Relation < ROM::Relation
      include ROM::HTTP

      adapter :http

      schema_class HTTP::Schema
      schema_dsl HTTP::Schema::DSL
      schema_attr_class HTTP::Attribute

      forward :with_headers, :add_header, :with_options,
              :with_base_path, :with_path, :append_path,
              :with_request_method, :with_params, :add_params

      def primary_key
        schema.primary_key_name
      end

      def project(*names)
        with(schema: schema.project(*names.flatten))
      end

      def exclude(*names)
        with(schema: schema.exclude(*names))
      end

      def rename(mapping)
        with(schema: schema.rename(mapping))
      end

      def prefix(prefix)
        with(schema: schema.prefix(prefix))
      end

      # @see Dataset#insert
      def insert(*tuples)
        dataset.insert(*tuples.map { |t| input_schema[t] })
      end
      alias_method :<<, :insert

      # @see Dataset#update
      def update(*tuples)
        dataset.update(*tuples.map { |t| input_schema[t] })
      end

      # @see Dataset#delete
      def delete
        dataset.delete
      end
    end
  end
end
