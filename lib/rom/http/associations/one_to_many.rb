# frozen_string_literal: true

require 'rom/associations/one_to_many'

module ROM
  module HTTP
    module Associations
      class OneToMany < ROM::Associations::OneToMany
        def call(target: self.target)
          schema = target.schema.qualified
          relation = target

          if view
            apply_view(schema, relation)
          else
            raise 'must override view'
          end
        end
      end
    end
  end
end
