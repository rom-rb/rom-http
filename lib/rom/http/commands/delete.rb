# frozen_string_literal: true

module ROM
  module HTTP
    module Commands
      # HTTP Delete command
      #
      # @api public
      class Delete < ROM::Commands::Delete
        adapter :http

        # Sends an HTTP delete to the dataset path
        #
        # @api public
        def execute
          relation.delete
        end

        def assert_tuple_count
          # noop
        end
      end
    end
  end
end
