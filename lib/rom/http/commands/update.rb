module ROM
  module HTTP
    module Commands
      class Update < ROM::Commands::Update
        adapter :http

        def execute(tuples)
          Array(tuples).flat_map do |tuple|
            attributes = input[tuple]
            validator.call(attributes)
            relation.update(attributes.to_h)
          end.to_a
        end

        # H4xz0rz: We don't know the tuple count
        def tuple_count
          one? ? 1 : super
        end
      end
    end
  end
end
