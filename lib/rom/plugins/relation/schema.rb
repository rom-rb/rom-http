require 'dry/data'

module ROM
  module Plugins
    module Relation
      module Schema
        def self.included(klass)
          super

          klass.class_eval do
            def self.schema(&block)
              @__schema__ = Schema.create(&block) if block_given?
              @__schema__
            end
          end
        end

        class Schema
          attr_reader :schema
          attr_reader :coercer

          def self.create(&block)
            new.tap { |schema| schema.instance_eval(&block) }
          end

          def initialize(schema = {}, coercer = Dry::Data['hash'])
            @schema = schema
            @coercer = coercer
          end

          def attribute_names
            schema.keys
          end

          def apply(attributes = {})
            coercer.schema(schema).call(attributes)
          end

          private

          def attribute(name, type)
            schema[name] = type
          end
        end
      end
    end
  end
end


ROM.plugins do
  register :schema, ROM::Plugins::Relation::Schema, type: :relation
end
