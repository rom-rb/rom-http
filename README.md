# rom-http <a href="https://gitter.im/rom-rb/chat" target="_blank">![Join the chat at https://gitter.im/rom-rb/chat](https://badges.gitter.im/Join%20Chat.svg)</a>

<a href="https://rubygems.org/gems/rom-http" target="_blank">![Gem Version](https://badge.fury.io/rb/rom-http.svg)</a>
<a href="https://travis-ci.org/rom-rb/rom-http" target="_blank">![Build Status](https://travis-ci.org/rom-rb/rom-http.svg?branch=master)</a>
<a href="https://gemnasium.com/rom-rb/rom-http" target="_blank">![Dependency Status](https://gemnasium.com/rom-rb/rom-http.svg)</a>
<a href="https://codeclimate.com/github/rom-rb/rom-http" target="_blank">![Code Climate](https://codeclimate.com/github/rom-rb/rom-http/badges/gpa.svg)</a>
<a href="http://inch-ci.org/github/rom-rb/rom-http" target="_blank">![Documentation Status](http://inch-ci.org/github/rom-rb/rom-http.svg?branch=master&style=flat)</a>

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

### Extending

```ruby
require 'json'
require 'uri'
require 'net/http'

module ROM
  module MyAdapter
    class Dataset < ROM::HTTP::Dataset
      default_request_handler ->(dataset) do
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

      default_response_handler ->(response, dataset) do
        Array([JSON.parse(response.body)]).flatten
      end
    end

    class Gateway < ROM::HTTP::Gateway; end

    class Relation < ROM::HTTP::Relation
      adapter :my_adapter
    end

    module Commands
      class Create < ROM::HTTP::Commands::Create
        adapter :my_adapter
      end

      class Update < ROM::HTTP::Commands::Create
        adapter :my_adapter
      end

      class Delete < ROM::HTTP::Commands::Create
        adapter :my_adapter
      end
    end
  end
end

ROM.register_adapter(:my_adapter, ROM::MyAdapter)

rom = ROM::Environment.new
rom.setup(:my_adapter, {
  uri: 'http://jsonplaceholder.typicode.com',
  headers: {
    Accept: 'application/json'
  }
})

class Users < ROM::Relation[:my_adapter]
  dataset :users

  def by_id(id)
    with_path(id.to_s)
  end
end

rom.register_relation(Users)

container = rom.finalize.env
container.relation(:users).by_id(1).to_a
# => GET http://jsonplaceholder.typicode.com/users/1 [ Accept: application/json ]
```
