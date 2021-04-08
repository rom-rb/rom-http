# frozen_string_literal: true

require "rom/associations/one_to_many"

module ROM
  module HTTP
    module Associations
      # OneToMany implementation
      class OneToMany < ROM::Associations::OneToMany
        def call(target: self.target)
          raise MissingAssociationViewError, "must override view" unless view

          schema = target.schema.qualified
          relation = target
          apply_view(schema, relation)
        end
      end
    end
  end
end
