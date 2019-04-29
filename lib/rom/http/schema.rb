# frozen_string_literal: true

require 'rom/schema'
require 'rom/http/types'

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
    end
  end
end
