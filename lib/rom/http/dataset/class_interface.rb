module ROM
  module HTTP
    # HTTP Dataset
    #
    # Represents a specific HTTP collection resource
    #
    # @api public
    class Dataset
      # @api private
      module ClassInterface
        # TODO: Remove in favour of configuration
        def default_request_handler(handler = Undefined)
          ::Dry::Core::Deprecations.announce(
            __method__,
            'use configuration instead'
          )
          return config.default_request_handler if Undefined === handler
          config.default_request_handler = handler
        end

        # TODO: Remove in favour of configuration
        def default_response_handler(handler = Undefined)
          ::Dry::Core::Deprecations.announce(
            __method__,
            'use configuration instead'
          )
          return config.default_response_handler if Undefined === handler
          config.default_response_handler = handler
        end
      end
    end
  end
end
