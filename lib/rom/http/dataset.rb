# frozen_string_literal: true

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

      extend Dry::Configurable
      extend ROM::Initializer

      include ROM::Memoizable
      include Enumerable
      include Dry::Equalizer(:options)

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

      # @!method self.query_param_encoder
      #   Return configured query param encoder
      #
      #   @example
      #     class MyDataset < ROM::HTTP::Dataset
      #       configure do |config|
      #         config.query_param_encoder = MyParamEncoder
      #       end
      #     end
      #
      #     MyDataset.query_param_encoder # MyParamEncoder
      #     MyDataset.new(uri: "http://localhost").query_param_encoder # MyParamEncoder
      setting :query_param_encoder, URI.method(:encode_www_form), reader: true

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
      option :request_method, type: Types::Symbol, default: proc { :get }

      # @!attribute [r] base_path
      #   @return [String]
      #   @api public
      option :base_path, type: Types::Path, default: proc { EMPTY_STRING }

      # @!attribute [r] path
      #   @return [String]
      #   @api public
      option :path, type: Types::Path, default: proc { EMPTY_STRING }

      # @!attribute [r] query_params
      #   @return [Hash]
      #   @api public
      option :query_params, type: Types::Hash, default: proc { EMPTY_HASH }

      # @!attribute [r] body_params
      #   @return [Hash]
      #   @api public
      option :body_params, type: Types::Hash, default: proc { EMPTY_HASH }

      # @!attribute [r] headers
      #   @return [Hash]
      #   @api public
      option :headers, type: Types::Hash, default: proc { EMPTY_HASH }

      # @!attribute [r] headers
      #   @return [Hash]
      #   @api public
      option :query_param_encoder, default: proc { self.class.query_param_encoder }

      # @!attribute [r] uri
      #   @return [String]
      #   @api public
      option :uri, type: Types::String

      # Return the dataset's URI
      #
      # @return [URI::HTTP]
      #
      # @api public
      def uri
        uri = URI(join_path(super, path))

        if query_params.any?
          uri.query = query_param_encoder.call(query_params)
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
        join_path(base_path, super)
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
        __new__(**options.merge(opts))
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
        with_path(join_path(options[:path], append_path))
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

      # Return a new dataset with replaced request query parameters
      #
      # @param [Hash] query_params the new request query parameters
      #
      # @example
      #   users = Dataset.new(query_params: { uid: 33 })
      #   users.with_query_params(login: 'jdoe').query_params
      #   # => { :login => 'jdoe' }
      #
      # @return [Dataset]
      #
      # @api public
      def with_query_params(query_params)
        with_options(query_params: query_params)
      end

      # Return a new dataset with merged request query parameters
      #
      # @param [Hash] query_params the new request query parameters to add
      #
      # @example
      #   users = Dataset.new(query_params: { uid: 33 })
      #   users.add_query_params(login: 'jdoe').query_params
      #   # => { uid: 33, :login => 'jdoe' }
      #
      # @return [Dataset]
      #
      # @api public
      def add_query_params(new_query_params)
        with_options(query_params: ::ROM::HTTP::Transformer[:deep_merge][query_params, new_query_params])
      end

      # Return a new dataset with replaced request body parameters
      #
      # @param [Hash] body_params the new request body parameters
      #
      # @example
      #   users = Dataset.new(body_params: { uid: 33 })
      #   users.with_body_params(login: 'jdoe').body_params
      #   # => { :login => 'jdoe' }
      #
      # @return [Dataset]
      #
      # @api public
      def with_body_params(body_params)
        with_options(body_params: body_params)
      end

      # Return a new dataset with merged request body parameters
      #
      # @param [Hash] body_params the new request body parameters to add
      #
      # @example
      #   users = Dataset.new(body_params: { uid: 33 })
      #   users.add_body_params(login: 'jdoe').body_params
      #   # => { uid: 33, :login => 'jdoe' }
      #
      # @return [Dataset]
      #
      # @api public
      def add_body_params(new_body_params)
        with_options(body_params: ::ROM::HTTP::Transformer[:deep_merge][body_params, new_body_params])
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
      # @param [Hash] attributes the attributes to insert
      #
      # @return [Array<Hash>]
      #
      # @api public
      def insert(attributes)
        with_options(
          request_method: :post,
          body_params: attributes
        ).response
      end

      # Perform an update over HTTP Put
      #
      # @param [Hash] attributes the attributes to update
      #
      # @return [Array<Hash>]
      #
      # @api public
      def update(attributes)
        with_options(
          request_method: :put,
          body_params: attributes
        ).response
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

      memoize :uri, :absolute_path

      private

      # @api private
      def __new__(*args, **kwargs, &block)
        self.class.new(*args, **kwargs, &block)
      end

      # @api private
      def join_path(*paths)
        paths.reject(&:empty?).join(PATH_SEPARATOR)
      end
    end
  end
end
