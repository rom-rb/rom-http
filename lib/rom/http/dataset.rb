module ROM
  module HTTP
    # HTTP Dataset
    #
    # Represents a specific HTTP collection resource
    #
    # @api public
    class Dataset
      PATH_SEPARATOR = '/'.freeze
      STRIP_PATH = ->(path) { path.sub(%r{\A/}, '') }.freeze

      include Enumerable
      include Dry::Equalizer(:config, :options)
      include ROM::Options

      attr_reader :config

      option :request_method, type: ::Symbol, default: :get, reader: true
      option :base_path, type: ::String, default: '', coercer: STRIP_PATH
      option :path, type: ::String, default: '', coercer: STRIP_PATH
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


      # HTTP Dataset interface
      #
      # @param [Hash] config the Gateway's HTTP server configuration
      #
      # @param [Hash] options dataset configuration options
      # @option options [Symbol] :request_method (:get) The HTTP verb to use
      # @option options [Array]  :projections ([]) Keys to select from response tuple
      # @option options [String] :path ('') URI request path
      # @option options [Hash] :headers ({}) Additional request headers
      # @option options [Hash] :params ({}) HTTP request parameters
      #
      # @api public
      def initialize(config, options = {})
        @config = config
        super(options)
      end

      # Return the gateway's URI
      #
      # @return [String]
      #
      # @raise [Error] if the configuration does not contain a URI
      #
      # @api public
      def uri
        config.fetch(:uri) { fail Error, ':uri configuration missing' }
      end

      # Return request headers
      #
      # Merges default headers from the Gateway configuration and the
      # current Dataset
      #
      # @example
      #   config = { Accepts: 'application/json' }
      #   users  = Dataset.new(config, headers: { 'Cache-Control': 'no-cache' }
      #   users.headers
      #   # => {:Accepts => "application/json", :'Cache-Control' => 'no-cache'}
      #
      # @return [Hash]
      #
      # @api public
      def headers
        config.fetch(:headers, {}).merge(options.fetch(:headers, {}))
      end

      # Return the dataset name
      #
      # @return [String]
      #
      # @api public
      def name
        config[:name].to_s
      end

      # Return the base path
      #
      # @example
      #   Dataset.new(config, base_path: '/users').base_path
      #   # => 'users'
      #
      # @return [String] the dataset path, without a leading slash
      #
      # @api public
      def base_path
        options[:base_path].empty? ? name : options[:base_path]
      end

      # Return the dataset path
      #
      # @example
      #   Dataset.new(config, path: '/users').path
      #   # => 'users'
      #
      # @return [String] the dataset path, without a leading slash
      #
      # @api public
      def path
        join_path(base_path, options[:path])
      end

      # Return the dataset path
      #
      # @example
      #   Dataset.new(config, path: '/users').path
      #   # => '/users'
      #
      # @return [string] the dataset path, with leading slash
      #
      # @api public
      def absolute_path
        PATH_SEPARATOR + path
      end

      # Return a new dataset with given headers
      #
      # @param headers [Hash] The new headers
      #
      # @note this _replaces_ the dataset's currently configured headers.
      #   To non-destructively add a new header, use `#add_header`
      #
      # @example
      #   users = Dataset.new(config, headers: { Accept: 'application/json' })
      #   users.with_headers(:'X-Api-Key' => '1234').headers
      #   # => { :'X-Api-Key' => '1234' }
      #
      # @return [Dataset]
      #
      # @api public
      def with_headers(headers)
        __new__(config, options.merge(headers: headers))
      end

      # Return a new dataset with additional header
      #
      # @param header [Symbol] the HTTP header to add
      # @param value  [String] the header value
      #
      # @example
      #   users = Dataset.new(config, headers: { Accept: 'application/json' })
      #   users.add_header(:'X-Api-Key', '1234').headers
      #   # => { :Accept => 'application/json', :'X-Api-Key' => '1234' }
      #
      # @return [Dataset]
      #
      # @api public
      def add_header(header, value)
        with_headers(headers.merge(header => value))
      end

      # Return a new dataset with additional options
      #
      # @param opts [Hash] the new options to add
      #
      # @return [Dataset]
      #
      # @api public
      def with_options(opts)
        __new__(config, options.merge(opts))
      end

      # Return a new dataset with a different base path
      #
      # @param base_path [String] the new base request path
      #
      # @example
      #   users.with_base_path('/profiles').base_path
      #   # => 'profiles'
      #
      # @return [Dataset]
      #
      # @api public
      def with_base_path(base_path)
        with_options(base_path: base_path)
      end

      # Return a new dataset with a different path
      #
      # @param path [String] the new request path
      #
      # @example
      #   users.with_path('/profiles').path
      #   # => 'profiles'
      #
      # @return [Dataset]
      #
      # @api public
      def with_path(path)
        with_options(path: path)
      end

      # Return a new dataset with a modified path
      #
      # @param path [String] new path fragment
      #
      # @example
      #   users.append_path('profiles').path
      #   # => users/profiles
      #
      # @return [Dataset]
      #
      # @api public
      def append_path(path)
        with_options(path: join_path(options[:path], path))
      end

      # Return a new dataset with a different request method
      #
      # @param [Symbol] request_method the new HTTP verb
      #
      # @example
      #   users.request_method(:put)
      #
      # @return [Dataset]
      #
      # @api public
      def with_request_method(request_method)
        with_options(request_method: request_method)
      end

      # Return a new dataset with replaced request parameters
      #
      # @param [Hash] params the new request parameters
      #
      # @example
      #   users = Dataset.new(config, params: { uid: 33 })
      #   users.with_params(login: 'jdoe').params
      #   # => { :login => 'jdoe' }
      #
      # @return [Dataset]
      #
      # @api public
      def with_params(params)
        with_options(params: params)
      end

      # Iterate over each response value
      #
      # @yield [Hash] a dataset tuple
      #
      # @return [Enumerator] if no block is given
      # @return [Array<Hash>]
      #
      # @api public
      def each(&block)
        return to_enum unless block_given?
        response.each(&block)
      end

      # Perform an insert over HTTP Post
      #
      # @params [Hash] params The request parameters to send
      #
      # @return [Array<Hash>]
      #
      # @api public
      def insert(params)
        with_options(
          request_method: :post,
          params: params
        ).response
      end

      # Perform an update over HTTP Put
      #
      # @params [Hash] params The request parameters to send
      #
      # @return [Array<Hash>]
      #
      # @api public
      def update(params)
        with_options(
          request_method: :put,
          params: params
        ).response
      end

      # Perform an delete over HTTP Delete
      #
      #
      # @return [Array<Hash>]
      #
      # @api public
      def delete
        with_options(
          request_method: :delete
        ).response
      end

      # Execute the current dataset
      #
      # @return [Array<hash>]
      #
      # @api public
      def response
        response_handler.call(request_handler.call(self), self)
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

      def join_path(*paths)
        paths.reject(&:empty?).join(PATH_SEPARATOR)
      end
    end
  end
end
