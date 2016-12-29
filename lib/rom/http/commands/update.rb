module ROM
  module HTTP
    module Commands
      # HTTP update command
      #
      # @api public
      class Update < ROM::Commands::Update
        adapter :http

        # Submits each of the provided tuples via HTTP put
        #
        # @api public
        def execute(tuples)
          Array([tuples]).flatten.map do |tuple|
            attributes = input[tuple]
            relation.update(attributes.to_h)
          end.to_a
        end

        def assert_tuple_count
          # noop
        end
      end
    end
  end
end
