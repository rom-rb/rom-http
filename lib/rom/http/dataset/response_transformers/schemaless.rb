require 'rom/http/support/transformations'

module ROM
  module HTTP
    class Dataset
      module ResponseTransformers
        class Schemaless
          def call(response, dataset)
            if dataset.projections.empty?
              response
            else
              t(:map_array, t(:accept_keys, dataset.projections)).call(response)
            end
          end

          private

          def t(*args)
            ROM::HTTP::Support::Transformations[*args]
          end
        end
      end
    end
  end
end
