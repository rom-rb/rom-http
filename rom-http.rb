require 'rspec'
require 'json'
require 'rom'

require 'rom/memory/dataset'

module ROM
  module HTTP
    class Connection
      attr_reader :url

      # gets base url
      def initialize(url)
        @url = url
      end

      # gets specific path, could receive more params
      def get(path)
        # FAKING RESPONSE
        [{ id: 1, name: 'Jane' }, { id: 2, name: 'John' }].to_json
      end
    end

    # http dataset is empty on initialization, it needs to receive a message
    # to load specific data from specific end-point
    #
    # it uses http connection collaborator to talk to the api
    #
    # it inherits from memory dataset so that it acts like an array
    #
    # specific interface of this dataset can be exposed to concrete relation classes
    # of an api adapter that uses this as a base
    class Dataset < ROM::Memory::Dataset
      option :http, reader: true

      # not really needed, but something to consider as a preprocessing step
      def self.row_proc
        Transproc(:hash_recursion, Transproc(:symbolize_keys))
      end

      # this could be implemented by concrete adapter for specific API
      def users
        __new__(load(:all)) # just faking something
      end

      private

      def load(path)
        JSON.load(http.get(path))
      end

      def __new__(dataset)
        self.class.new(dataset, options) # this could be provided by memory ds
      end
    end

    class Repository < ROM::Repository
      attr_reader :http

      def initialize(url)
        @http = Connection.new(url)
        @datasets = {}
      end

      def dataset(name)
        @datasets[name] = Dataset.new([], http: http)
      end
    end

    class Relation < ROM::Relation
      forward :restrict, :users # exposing some native interface to relation
    end
  end
end

RSpec.describe 'rom-http' do
  it 'works' do
    class Resources < ROM::HTTP::Relation
      def by(criteria)
        restrict(criteria)
      end
    end

    repo = ROM::HTTP::Repository.new('http://some.api.url.com')
    dataset = repo.dataset(:resources)

    resources = Resources.new(dataset)

    expect(resources.users.by(name: 'Jane').to_a).to match_array([
      { id: 1, name: 'Jane' }
    ])
  end
end
