# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'json'

require 'rom/support/inflector'

module ROM
  module HTTP
    # Default request/response handlers
    #
    # @api public
    class Handlers
      # Default handler for JSON requests
      #
      # @api public
      class JSONRequest
        # Handle JSON request for the provided dataset
        #
        # @param [Dataset] dataset
        #
        # @return [Array<Hash>]
        #
        # @api public
        def self.call(dataset)
          uri = dataset.uri

          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true if uri.scheme.eql?('https')

          request_class = Net::HTTP.const_get(ROM::Inflector.classify(dataset.request_method))

          request = request_class.new(uri.request_uri)

          dataset.headers.each_with_object(request) do |(header, value), request|
            request[header.to_s] = value
          end

          request.body = JSON.dump(dataset.body_params) if dataset.body_params.any?

          http.request(request)
        end
      end

      # Default handler for JSON responses
      #
      # @api public
      class JSONResponse
        # Handle JSON responses
        #
        # @param [Net::HTTP::Response] response
        # @param [Dataset] dataset
        #
        # @return [Array<Hash>]
        #
        # @api public
        def self.call(response, dataset)
          Array([JSON.parse(response.body)]).flatten(1)
        end
      end
    end
  end
end
