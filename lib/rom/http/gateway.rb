require 'concurrent'
require 'rom/http/dataset'

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
      private :datasets, :config

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
        dataset_klass = namespace.const_defined?(:Dataset) ? namespace.const_get(:Dataset) : Dataset
        datasets[name] = dataset_klass.new(config.merge(name: name))
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

      def namespace
        self.class.to_s[/(.*)(?=::)/].split('::').inject(::Object) do |constant, const_name|
          constant.const_get(const_name)
        end
      end
    end
  end
end
