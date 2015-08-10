# rom-http

HTTP adapter for ROM

### Synopsis

```ruby
require 'json'
require 'faraday'

class RequestHandler
  attr_reader :connections

  def initialize
    @connections = ThreadSafe::Hash.new do |hash, uri|
      hash[uri] = Faraday.new(uri) do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.response :logger
      end
    end
  end

  def call(dataset)
    connection(dataset.uri).send(
      dataset.request_method,
      dataset.name,
      dataset.params,
      dataset.headers
    )
  end

  private

  def connection(uri)
    connections[uri]
  end
end

class ResponseHandler
  def call(response, dataset)
    JSON.parse(response.body)['_embedded'][dataset.name]
  end
end

ROM.setup(:http, {
  uri: 'http://localhost:3000',
  headers: {
    accept: 'application/json'
  },
  request_handler: RequestHandler.new,
  response_handler: ResponseHandler.new
})

class Users < ROM::Relation[:http]
  dataset :users
end

rom = ROM.finalize.env
rom.relation(:users).to_a
```
