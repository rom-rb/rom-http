[gem]: https://rubygems.org/gems/rom-http
[travis]: https://travis-ci.org/rom-rb/rom-http
[codeclimate]: https://codeclimate.com/github/rom-rb/rom-http
[inchpages]: http://inch-ci.org/github/rom-rb/rom-http

# rom-http

[![Gem Version](https://badge.fury.io/rb/rom-http.svg)][gem]
[![Build Status](https://travis-ci.org/rom-rb/rom-http.svg?branch=master)][travis]
[![Code Climate](https://codeclimate.com/github/rom-rb/rom-http/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/rom-rb/rom-http/badges/coverage.svg)][codeclimate]
[![Inline docs](http://inch-ci.org/github/rom-rb/rom-http.svg?branch=master)][inchpages]

HTTP adapter for [rom-rb](https://github.com/rom-rb/rom).

Resources:

- [User Documentation](http://rom-rb.org/learn/http/)
- [API Documentation](http://rubydoc.info/gems/rom-http)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rom-http'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rom-http

## License

See `LICENSE` file.

## Synopsis

```ruby
require 'inflecto'
require 'json'
require 'uri'
require 'net/http'

class RequestHandler
  def call(dataset)
    uri = dataset.uri
    http = Net::HTTP.new(uri.host, uri.port)
    request_klass = Net::HTTP.const_get(Inflecto.classify(dataset.request_method))

    request = request_klass.new(uri.request_uri)
    dataset.headers.each_with_object(request) do |(header, value), request|
      request[header.to_s] = value
    end

    response = http.request(request)
  end
end

class ResponseHandler
  def call(response, dataset)
    if %i(post put patch).include?(dataset.request_method)
      JSON.parse(response.body, symbolize_names: true)
    else
      Array([JSON.parse(response.body, symbolize_names: true)]).flatten
    end
  end
end

class Users < ROM::Relation[:http]
  schema(:users) do
    attribute :id, ROM::Types::Integer
    attribute :name, ROM::Types::String
    attribute :username, ROM::Types::String
    attribute :email, ROM::Types::String
    attribute :phone, ROM::Types::String
    attribute :website, ROM::Types::String
  end

  def by_id(id)
    with_path(id.to_s)
  end
end

configuration = ROM::Configuration.new(:http, {
  uri: 'http://jsonplaceholder.typicode.com',
  headers: {
    Accept: 'application/json'
  },
  request_handler: RequestHandler.new,
  response_handler: ResponseHandler.new
})
configuration.register_relation(Users)
container = ROM.container(configuration)

container.relation(:users).by_id(1).to_a
# => GET http://jsonplaceholder.typicode.com/users/1 [ Accept: application/json ]
```

### Extending

```ruby
require 'inflecto'
require 'json'
require 'uri'
require 'net/http'

module ROM
  module MyAdapter
    class Dataset < ROM::HTTP::Dataset
      configure do |config|
        config.default_request_handler = ->(dataset) do
          uri = dataset.uri

          http = Net::HTTP.new(uri.host, uri.port)
          request_klass = Net::HTTP.const_get(Inflecto.classify(dataset.request_method))

          request = request_klass.new(uri.request_uri)
          dataset.headers.each_with_object(request) do |(header, value), request|
            request[header.to_s] = value
          end

          response = http.request(request)
        end

        config.default_response_handler = ->(response, dataset) do
          if %i(post put patch).include?(dataset.request_method)
            JSON.parse(response.body, symbolize_names: true)
          else
            Array([JSON.parse(response.body, symbolize_names: true)]).flatten
          end
        end
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

      class Update < ROM::HTTP::Commands::Update
        adapter :my_adapter
      end

      class Delete < ROM::HTTP::Commands::Delete
        adapter :my_adapter
      end
    end
  end
end

ROM.register_adapter(:my_adapter, ROM::MyAdapter)

configuration = ROM::Configuration.new(:my_adapter, {
  uri: 'http://jsonplaceholder.typicode.com',
  headers: {
    Accept: 'application/json'
  }
})

class Users < ROM::Relation[:my_adapter]
  schema(:users) do
    attribute :id, ROM::Types::Integer
    attribute :name, ROM::Types::String
    attribute :username, ROM::Types::String
    attribute :email, ROM::Types::String
    attribute :phone, ROM::Types::String
    attribute :website, ROM::Types::String
  end

  def by_id(id)
    with_path(id.to_s)
  end
end

configuration.register_relation(Users)
container = ROM.container(configuration)

container.relation(:users).by_id(1).to_a
# => GET http://jsonplaceholder.typicode.com/users/1 [ Accept: application/json ]
```
