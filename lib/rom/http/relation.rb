module ROM
  module HTTP
    class Relation < ROM::Relation
      include Enumerable

      adapter :http

      forward :with_request_method, :with_path, :append_path, :with_options,
              :with_params, :clear_params, :project

      def insert(*args)
        dataset.insert(*args)
      end
      alias_method :<<, :insert

      def update(*args)
        dataset.update(*args)
      end

      def delete
        dataset.delete
      end
    end
  end
end
