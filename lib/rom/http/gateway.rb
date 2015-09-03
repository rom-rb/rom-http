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
        dataset_klass = namespace.const_defined?(:Dataset) ? namespace.const_get(:Dataset) : Dataset
        datasets[name] = dataset_klass.new(config.merge(name: name))
      end

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
