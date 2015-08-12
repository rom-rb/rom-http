module ROM
  module HTTP
    module Commands
      class Update < ROM::Commands::Update
        adapter :http

        def execute(tuples)
          Array([tuples]).flatten.map do |tuple|
            attributes = input[tuple]
            validator.call(attributes)
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
