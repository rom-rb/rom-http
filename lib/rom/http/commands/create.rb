module ROM
  module HTTP
    module Commands
      #  HTTP Create command
      #
      #  @api public
      class Create < ROM::Commands::Create
        adapter :http

        # Submits each of the provided tuples over HTTP post
        #
        # @api public
        def execute(tuples)
          Array([tuples]).flatten.map do |tuple|
            attributes = input[tuple]
            relation.insert(attributes.to_h)
          end.to_a
        end
      end
    end
  end
end
