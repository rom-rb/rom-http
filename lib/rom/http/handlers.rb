require "rom/http/handlers/json"

module ROM
  module HTTP
    # Request/response handler registry
    #
    # @api public
    class Handlers
      extend Dry::Container::Mixin

      register(:json, request: JSONRequest, response: JSONResponse)
    end
  end
end
