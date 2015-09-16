require 'rom/http/support/transformations'

module ROM
  module HTTP
    class Dataset
      include Enumerable
      include Equalizer.new(:config, :options)
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
        super(options)
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
          response_handler.call(request_handler.call(self), self)
        )
      end

      private

      def response_handler
        config.fetch(:response_handler, default_response_handler).tap do |response_handler|
          fail Error, ':response_handler configuration missing' if response_handler.nil?
        end
      end

      def request_handler
        config.fetch(:request_handler, default_request_handler).tap do |request_handler|
          fail Error, ':response_handler configuration missing' if request_handler.nil?
        end
      end

      def default_response_handler
        self.class.default_response_handler
      end

      def default_request_handler
        self.class.default_request_handler
      end

      def response_transformer
        if projections.empty?
          ROM::HTTP::Support::Transformations[:noop]
        else
          ROM::HTTP::Support::Transformations[:apply_projections, projections]
        end
      end

      def __new__(*args, &block)
        self.class.new(*args, &block)
      end
    end
  end
end
