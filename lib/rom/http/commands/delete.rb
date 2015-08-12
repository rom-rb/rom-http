module ROM
  module HTTP
    module Commands
      class Delete < ROM::Commands::Delete
        adapter :http

        def execute
          relation.delete
        end

        def assert_tuple_count
          # noop
        end
      end
    end
  end
end
