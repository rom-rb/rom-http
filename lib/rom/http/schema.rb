# frozen_string_literal: true

require "rom/schema"
require "rom/http/types"

module ROM
  module HTTP
    class Schema < ROM::Schema
      # Customized output hash constructor which symbolizes keys
      # and optionally applies custom read-type coercions
      #
      # @api private
      def to_output_hash
        Types::Hash
          .schema(map { |attr| [attr.key, attr.to_read_type] }.to_h)
          .with_key_transform(&:to_sym)
      end

      # To maintain compatibility with other adapters
      #
      # @api private
      def qualified
        self
      end

      # Internal hook used during setup process
      #
      # @see Schema#finalize_associations!
      #
      # @api private
      def finalize_associations!(relations:)
        super do
          associations.map do |definition|
            HTTP::Associations.const_get(definition.type).new(definition, relations)
          end
        end
      end
    end
  end
end
