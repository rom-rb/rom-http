require 'thread_safe'
require 'rom/http/dataset'

module ROM
  module HTTP
    class Gateway < ROM::Gateway
      attr_reader :datasets, :config, :options
      private :datasets, :config, :options

      def initialize(config = {}, options = {})
        @datasets = ThreadSafe::Cache.new
        @config = config
        @options = options
      end

      def [](name)
        datasets.fetch(name)
      end

      def dataset(name)
        datasets[name] = Dataset.new(config.merge(name: name), options)
      end

      def dataset?(name)
        datasets.key?(name)
      end
    end
  end
end
