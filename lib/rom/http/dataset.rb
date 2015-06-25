module ROM
  module HTTP
    class Dataset
      include Enumerable

      attr_reader :config, :options

      def initialize(config, options = {})
        @config = config
        @options = {
          request_method: :get,
          path: '',
          params: {}
        }.merge(options)
      end

      def url
        config[:url]
      end

      def headers
        {}
      end

      def name
        config[:name]
      end

      def path
        options[:path].to_s
      end

      def request_method
        options[:request_method]
      end

      def params
        options[:params]
      end

      def with_options(opts)
        self.class.new(config, options.merge(opts))
      end

      def with_path(path)
        with_options(path: path)
      end

      def prepend_path(path)
        with_options(path: File.join(path, options[:path]))
      end

      def append_path(path)
        with_options(path: File.join(options[:path], path))
      end

      def with_request_method(request_method)
        with_options(request_method: request_method)
      end

      def with_params(params)
        with_options(params: params)
      end

      def clear_params
        with_options(params: {})
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

      def delete(params)
        with_options(
          request_method: :delete,
          params: params
        ).response
      end

      def response
        response_handler.call(self, request_handler.call(self))
      end

      private

      def response_handler
        config[:response_handler]
      end

      def request_handler
        config[:request_handler]
      end
    end
  end
end
