require 'thread_safe'
require 'rom/http/dataset'

module ROM
  module HTTP
    class Gateway < ROM::Gateway
      attr_reader :datasets, :config
      private :datasets, :config

      def initialize(config)
        @datasets = ThreadSafe::Cache.new
        @config = config
      end

      def [](name)
        datasets.fetch(name)
      end

      def dataset(name)
        datasets[name] = Dataset.new(config.merge(name: name))
      end

      def dataset?(name)
        datasets.key?(name)
      end
    end
  end
end
