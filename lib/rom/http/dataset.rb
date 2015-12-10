require 'rom/http/dataset/response_transformers/schemad'
require 'rom/http/dataset/response_transformers/schemaless'

module ROM
  module HTTP
    class Dataset
      include Enumerable
      include Dry::Equalizer(:config, :options)
      include ROM::Options

      attr_reader :config

      option :projections, type: ::Array, default: [], reader: true
      option :request_method, type: ::Symbol, default: :get, reader: true
      option :path, type: ::String, default: ''
      option :params, type: ::Hash, default: {}, reader: true
      option :headers, type: ::Hash, default: {}

      class << self
        def default_request_handler(handler = Undefined)
          return @default_request_handler if Undefined === handler
          @default_request_handler = handler
        end

        def default_response_handler(handler = Undefined)
          return @default_response_handler if Undefined === handler
          @default_response_handler = handler
        end
      end

      def initialize(config, options = {})
        @config = config
        @response_transformer = ResponseTransformers::Schemaless.new
        super(options)
      end

      def response_transformer(transformer = Undefined)
        return @response_transformer if Undefined === transformer
        @response_transformer = transformer
      end

      def uri
        config.fetch(:uri) { fail Error, ':uri configuration missing' }
      end

      def headers
        config.fetch(:headers, {}).merge(options.fetch(:headers, {}))
      end

      def name
        config[:name].to_s
      end

      def path
        options[:path].to_s.sub(%r{\A/}, '')
      end

      def absolute_path
        '/' + path
      end

      def with_headers(headers)
        __new__(config, options.merge(headers: headers))
      end

      def add_header(header, value)
        with_headers(headers.merge(header => value))
      end

      def with_options(opts)
        __new__(config, options.merge(opts))
      end

      def project(*args)
        projections = args.first.is_a?(::Array) ? args.first : args

        with_options(
          projections: (self.projections + projections)
        )
      end

      def with_path(path)
        with_options(path: path)
      end

      def append_path(path)
        with_options(path: options[:path] + '/' + path)
      end

      def with_request_method(request_method)
        with_options(request_method: request_method)
      end

      def with_params(params)
        with_options(params: params)
      end

      def each(&block)
        return to_enum unless block_given?
        response.each(&block)
      end

      def insert(params)
        with_options(
          request_method: :post,
          params: params
        ).response
      end

      def update(params)
        with_options(
          request_method: :put,
          params: params
        ).response
      end

      def delete
        with_options(
          request_method: :delete
        ).response
      end

      def response
        response_transformer.call(
          response_handler.call(request_handler.call(self), self),
          self
        )
      end

      private

      def response_handler
        response_handler = config.fetch(:response_handler, self.class.default_response_handler)
        fail Error, ':response_handler configuration missing' if response_handler.nil?
        response_handler
      end

      def request_handler
        request_handler = config.fetch(:request_handler, self.class.default_request_handler)
        fail Error, ':response_handler configuration missing' if request_handler.nil?
        request_handler
      end

      def __new__(*args, &block)
        self.class.new(*args, &block)
      end
    end
  end
end
