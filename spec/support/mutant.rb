# frozen_string_literal: true

module Mutant
  class Selector
    # Expression based test selector
    class Expression < self
      def call(_subject)
        integration.all_tests
      end
    end
  end
end
