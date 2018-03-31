require 'uri'

require 'dry/configurable'
require 'dry/core/deprecations'

require 'rom/support/memoizable'
require 'rom/constants'
require 'rom/initializer'
require 'rom/http/types'
require 'rom/http/transformer'

module ROM
  module HTTP
    # HTTP Dataset
    #
    # Represents a specific HTTP collection resource. This class can be
    # subclassed in a specialized HTTP adapter to provide its own
    # response/request handlers or any other configuration that should
    # differ from the defaults.
    #
    # @api public
    class Dataset
      PATH_SEPARATOR = '/'.freeze

      extend ::ROM::Initializer
      extend ::Dry::Configurable
      include ::ROM::Memoizable
      include ::Enumerable
      include ::Dry::Equalizer(:options)

      # @!method self.default_request_handler
      #   Return configured default request handler
      #
      #   @example
      #     class MyDataset < ROM::HTTP::Dataset
      #       configure do |config|
      #         config.default_request_handler = MyRequestHandler
      #       end
      #     end
      #
      #     MyDataset.default_request_handler # MyRequestHandler
      #     MyDataset.new(uri: "http://localhost").request_handler # MyRequestHandler
      setting :default_request_handler, reader: true

      # @!method self.default_response_handler
      #   Return configured default response handler
      #
      #   @example
      #     class MyDataset < ROM::HTTP::Dataset
      #       configure do |config|
      #         config.default_response_handler = MyResponseHandler
      #       end
      #     end
      #
      #     MyDataset.default_response_handler # MyResponseHandler
      #     MyDataset.new(uri: "http://localhost").response_handler # MyResponseHandler
      setting :default_response_handler, reader: true

      # @!method self.param_encoder
      #   Return configured param encoder
      #
      #   @example
      #     class MyDataset < ROM::HTTP::Dataset
      #       configure do |config|
      #         config.param_encoder = MyParamEncoder
      #       end
      #     end
      #
      #     MyDataset.param_encoder # MyParamEncoder
      #     MyDataset.new(uri: "http://localhost").param_encoder # MyParamEncoder
      setting :param_encoder, URI.method(:encode_www_form), reader: true

      # @!attribute [r] request_handler
      #   @return [Object]
      #   @api public
      option :request_handler, default: proc { self.class.default_request_handler }

      # @!attribute [r] response_handler
      #   @return [Object]
      #   @api public
      option :response_handler, default: proc { self.class.default_response_handler }

      # @!attribute [r] request_method
      #   @return [Symbol]
      #   @api public
      option :request_method, type: Types::Symbol, default: proc { :get }, reader: true

      # @!attribute [r] base_path
      #   @return [String]
      #   @api public
      option :base_path, type: Types::Coercible::String, default: proc { EMPTY_STRING }

      # @!attribute [r] path
      #   @return [String]
      #   @api public
      option :path, type: Types::String, default: proc { '' }, reader: false

      # @!attribute [r] params
      #   @return [Hash]
      #   @api public
      option :params, type: Types::Hash, default: proc { {} }, reader: true

      # @!attribute [r] headers
      #   @return [Hash]
      #   @api public
      option :headers, type: Types::Hash, default: proc { {} }

      # @!attribute [r] headers
      #   @return [Hash]
      #   @api public
      option :param_encoder, default: proc { self.class.param_encoder }

      option :uri, type: Types::String, reader: false

      # Return the gateway's URI
      #
      # @return [String]
      #
      # @api public
      def uri
        uri = URI(join_path(options[:uri], path))

        if get? && params.any?
          uri.query = param_encoder.call(params)
        end

        uri
      end

      # Return true if request method is set to :get
      #
      # @return [Boolean]
      #
      # @api public
      def get?
        request_method.equal?(:get)
      end

      # Return true if request method is set to :post
      #
      # @return [Boolean]
      #
      # @api public
      def post?
        request_method.equal?(:post)
      end

      # Return true if request method is set to :put
      #
      # @return [Boolean]
      #
      # @api public
      def put?
        request_method.equal?(:put)
      end

      # Return true if request method is set to :delete
      #
      # @return [Boolean]
      #
      # @api public
      def delete?
        request_method.equal?(:delete)
      end

      # Return the base path
      #
      # @example
      #   Dataset.new(base_path: '/users').base_path
      #   # => 'users'
      #
      # @return [String] the dataset path, without a leading slash
      #
      # @api public
      def base_path
        strip_path(super)
      end

      # Return the dataset path
      #
      # @example
      #   Dataset.new(path: '/users').path
      #   # => 'users'
      #
      # @return [String] the dataset path, without a leading slash
      #
      # @api public
      def path
        join_path(base_path, strip_path(options[:path].to_s))
      end

      # Return the dataset path
      #
      # @example
      #   Dataset.new(path: '/users').path
      #   # => '/users'
      #
      # @return [String] the dataset path, with leading slash
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
      #   users = Dataset.new(headers: { Accept: 'application/json' })
      #   users.with_headers(:'X-Api-Key' => '1234').headers
      #   # => { :'X-Api-Key' => '1234' }
      #
      # @return [Dataset]
      #
      # @api public
      def with_headers(headers)
        with_options(headers: headers)
      end

      # Return a new dataset with additional header
      #
      # @param header [Symbol] the HTTP header to add
      # @param value  [String] the header value
      #
      # @example
      #   users = Dataset.new(headers: { Accept: 'application/json' })
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
        __new__(options.merge(opts))
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
      def append_path(append_path)
        with_options(path: join_path(path, append_path))
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
      #   users = Dataset.new(params: { uid: 33 })
      #   users.with_params(login: 'jdoe').params
      #   # => { :login => 'jdoe' }
      #
      # @return [Dataset]
      #
      # @api public
      def with_params(params)
        with_options(params: params)
      end

      # Return a new dataset with merged request parameters
      #
      # @param [Hash] params the new request parameters to add
      #
      # @example
      #   users = Dataset.new(params: { uid: 33 })
      #   users.add_params(login: 'jdoe').params
      #   # => { uid: 33, :login => 'jdoe' }
      #
      # @return [Dataset]
      #
      # @api public
      def add_params(new_params)
        with_options(params: ::ROM::HTTP::Transformer[:deep_merge][params, new_params])
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
        with_options(request_method: :post, params: params).response
      end

      # Perform an update over HTTP Put
      #
      # @params [Hash] params The request parameters to send
      #
      # @return [Array<Hash>]
      #
      # @api public
      def update(params)
        with_options(request_method: :put, params: params).response
      end

      # Perform an delete over HTTP Delete
      #
      #
      # @return [Array<Hash>]
      #
      # @api public
      def delete
        with_options(request_method: :delete).response
      end

      # Execute the current dataset
      #
      # @return [Array<hash>]
      #
      # @api public
      def response
        response_handler.call(request_handler.call(self), self)
      end

      memoize :uri, :base_path, :path, :absolute_path

      private

      # @api private
      def __new__(*args, &block)
        self.class.new(*args, &block)
      end

      # @api private
      def join_path(*paths)
        paths.reject(&:empty?).join(PATH_SEPARATOR)
      end

      # @api private
      def strip_path(path)
        path.sub(%r{\A/}, '')
      end
    end
  end
end
