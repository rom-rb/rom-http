module ROM
  module HTTP
    module Commands
      class Delete < ROM::Commands::Delete
        adapter :http

        def execute
          relation.delete
        end

        # H4xz0rz: We don't know the tuple count
        def tuple_count
          one? ? 1 : super
        end
      end
    end
  end
end
