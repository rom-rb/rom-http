# frozen_string_literal: true

require 'concurrent'

require 'rom/http/dataset'
require 'rom/http/handlers'
require 'rom/http/mapper_compiler'

module ROM
  module HTTP
    # HTTP gateway
    #
    # @example
    #   config = {
    #     uri: 'http://jsonplaceholder.typicode.com',
    #     headers: { Accept: 'applicaiton/json' }
    #   }
    #
    #   gateway = ROM::HTTP::Gateway.new(config)
    #   users   = gateway.dataset(:users)
    #
    # @api public
    class Gateway < ROM::Gateway
      adapter :http

      attr_reader :datasets, :config

      # HTTP gateway interface
      #
      # @param [Hash] config  configuration options
      #   @option config [String] :uri The base API for the HTTP service
      #   @option config [Hash] :headers Default request headers
      #
      # @see Dataset
      #
      # @api public
      def initialize(config)
        @datasets = Concurrent::Map.new
        @config = config
      end

      # Retrieve dataset with the given name
      #
      # @param [String] name dataaset name
      #
      # @return [Dataset]
      #
      # @api public
      def [](name)
        datasets.fetch(name)
      end

      # Build dataset with the given name
      #
      # @param [String] name dataaset name
      #
      # @return [Dataset]
      #
      # @api public
      def dataset(name)
        datasets[name] = dataset_class.new(dataset_options(name))
      end

      # Check if dataset exists
      #
      # @param [String] name dataset name
      #
      # @api public
      def dataset?(name)
        datasets.key?(name)
      end

      private

      # Return Dataset class
      #
      # @return [Class]
      #
      # @api private
      def dataset_class
        namespace.const_defined?(:Dataset) ? namespace.const_get(:Dataset) : Dataset
      end

      # Return Dataset options
      #
      # @return [Class]
      #
      # @api private
      def dataset_options(name)
        config.merge(uri: uri, base_path: name, **default_handlers)
      end

      # Return default handlers registered in Handlers registry
      #
      # @return [Hash]
      #
      # @api private
      def default_handlers
        if handlers_key = config[:handlers]
          Handlers[handlers_key]
            .map { |key, value| [:"#{key}_handler", value] }.to_h
        else
          EMPTY_HASH
        end
      end

      # @api private
      def uri
        config.fetch(:uri) { fail Error, '+uri+ configuration missing' }
      end

      # @api private
      def namespace
        self.class.to_s[/(.*)(?=::)/].split('::').inject(::Object) do |constant, const_name|
          constant.const_get(const_name)
        end
      end
    end
  end
end
