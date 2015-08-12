# rom-http

HTTP adapter for ROM

### Synopsis

```ruby
require 'json'
require 'uri'
require 'net/http'

class RequestHandler
  def call(dataset)
    uri = URI(dataset.uri)
    uri.path = "/#{dataset.name}/#{dataset.path}"
    uri.query = URI.encode_www_form(dataset.params)

    http = Net::HTTP.new(uri.host, uri.port)
    request_klass = Net::HTTP.const_get(ROM::Inflector.classify(dataset.request_method))

    request = request_klass.new(uri.request_uri)
    dataset.headers.each_with_object(request) do |(header, value), request|
      request[header.to_s] = value
    end

    response = http.request(request)
  end
end

class ResponseHandler
  def call(response, dataset)
    Array([JSON.parse(response.body)]).flatten
  end
end

class Users < ROM::Relation[:http]
  dataset :users

  def by_id(id)
    with_path(id.to_s)
  end
end

rom = ROM::Environment.new
rom.setup(:http, {
  uri: 'http://jsonplaceholder.typicode.com',
  headers: {
    Accept: 'application/json'
  },
  request_handler: RequestHandler.new,
  response_handler: ResponseHandler.new
})
rom.register_relation(Users)

container = rom.finalize.env
container.relation(:users).by_id(1).to_a
# => GET http://jsonplaceholder.typicode.com/users/1 [ Accept: application/json ]
```
