require 'rom/types'

module ROM
  module HTTP
    class Dataset
      module ResponseTransformers
        class Schemad
          attr_reader :schema

          def initialize(schema)
            @schema = Types::Hash.schema(schema)
          end

          def call(response, dataset)
            projections = dataset.projections

            if projections.size > 0 && schema.member_types.keys != projections
              projected_schema = Types::Hash.schema(
                schema.member_types.select { |k, _| projections.include?(k) }
              )
              projected_schema[response]
            else
              response.map { |tuple| schema[tuple] }
            end
          end
        end
      end
    end
  end
end
