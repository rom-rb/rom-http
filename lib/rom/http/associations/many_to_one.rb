# frozen_string_literal: true

require 'rom/associations/many_to_one'

module ROM
  module HTTP
    module Associations
      # ManyToOne implementation
      class ManyToOne < ROM::Associations::ManyToOne
        def call(target: self.target)
          raise MissingAssociationViewError, 'must override view' unless view

          schema = target.schema.qualified
          relation = target
          apply_view(schema, relation)
        end
      end
    end
  end
end
