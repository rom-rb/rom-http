module ROM
  module HTTP
    module Commands
      class Create < ROM::Commands::Create
        adapter :http

        def execute(tuples)
          Array([tuples]).flat_map do |tuple|
            attributes = input[tuple]
            validator.call(attributes)
            relation.insert(attributes.to_h)
          end.to_a
        end
      end
    end
  end
end
