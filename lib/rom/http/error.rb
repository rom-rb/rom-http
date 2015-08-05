module ROM
  module HTTP
    Error = Class.new(StandardError)

    class GatewayConfigurationError < Error
      def initialize(missing_keys)
        if missing_keys.length > 1
          msg = "Missing #{missing_keys[0..-1].join(', ')} and #{missing_keys.last}"
        else
          msg = "Missing #{missing_keys.last}"
        end

        super(msg + ' in ROM::HTTP::Gateway configuration')
      end
    end
  end
end
