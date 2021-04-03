# frozen_string_literal: true

require 'rom/http/associations/many_to_many'
require 'rom/http/associations/one_to_many'
require 'rom/http/associations/many_to_one'
require 'rom/http/associations/one_to_one'

module ROM
  module HTTP
    module Associations
      class MissingAssociationViewError < Error; end
    end
  end
end
