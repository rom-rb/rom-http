module ROM
  module HTTP
    module Commands
      class Update < ROM::Commands::Update
        adapter :http

        def execute(params)
          attributes = input[params]
          validator.call(attributes)
          relation.map { |tuple| tuple.update(attributes.to_h) }
        end
      end
    end
  end
end
