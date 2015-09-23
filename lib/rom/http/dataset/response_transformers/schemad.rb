require 'rom/http/support/transformations'

module ROM
  module HTTP
    class Dataset
      module ResponseTransformers
        class Schemad
          attr_reader :schema

          def initialize(schema)
            @schema = schema
          end

          def call(response, dataset)
            t(:map_array,
              t(:accept_keys, projections(dataset.projections)) >> ->(tuple) { schema.apply(tuple) }
             ).call(response)
          end

          private

          def t(*args)
            ROM::HTTP::Support::Transformations[*args]
          end

          def projections(projections)
            if projections.empty?
              schema.attribute_names
            else
              projections.reject { |attr| !schema.attribute_names.include?(attr) }
            end
          end
        end
      end
    end
  end
end
