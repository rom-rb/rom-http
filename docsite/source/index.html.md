---
position: 6
chapter: HTTP
---

$TOC
  1. [Installing](#installing)
  2. [Connecting to an HTTP API](#connection)
  3. [Relations](#connection)
  4. [Handlers](#handlers)
$TOC

ROM provides an abstract `HTTP` adapter that you can use to build HTTP client libraries. It provides powerful core features that work out-of-the-box. You have access to relation schemas, custom attribute types, aliasing, auto-mapping to structs, using custom struct namespaces and more.

Requests and responses can be handled by the built-in handlers, or you can register your own.

## Installing

*Depends on:* `ruby v2.4.0` or greater

To install <mark>rom-http</mark> add the following to your <mark>Gemfile</mark>.

```ruby
gem 'rom-http', '~> 0.8'
```

Afterwards either load `rom-http` through your bundler setup or manually in your custom
script like so:

```ruby
require 'rom-http'
```

Once loaded the http Adapter will register itself with ROM and become available
for immediate use via the `:http` identifier.

## Connection

When you set up an `HTTP` gateway, you need to specify at the URI. Let's say we want to connect to GitHub API. To configure a gateway:

```ruby
config = ROM::Configuration.new(:http, uri: "https://api.github.com", handlers: :json)
```

^INFO
  Setting up a gateway assumes that all registered relations will use the `uri` as the `base_path` for all requests.
^

## Relations

When you define relations for `HTTP` adapter, you need to specify the schemas as there's no way to infer them.

^INFO
  By defining schemas you tell `ROM` which attributes you're interested in, everything else will be rejected from the original responses.
^

Here's an example how you could define a relation to fetch organizations from GitHub:

```ruby
module GitHub
  module Resources
    class Organizations < ROM::Relation[:http]
      schema(:orgs) do
        attribute :id, Types::Integer
        attribute :name, Types::String
        attribute :created_at, Types::JSON::Time
        attribute :updated_at, Types::JSON::Time
      end

      def by_name(name)
        append_path(name)
      end
    end
  end
end

config.register_relation(GitHub::Resources::Organizations)

rom = ROM.container(config)
```

Now we can use our relation to query GitHub API:

```ruby
orgs = rom.relations[:orgs]

orgs.by_name('rom-rb').one
# {:id=>4589832, :name=>"rom-rb", :created_at=>2013-06-01 22:03:54 UTC, :updated_at=>2019-04-03 14:36:48 UTC}

orgs.with(auto_struct: true).by_name('rom-rb').one
# #<ROM::Struct::Org id=4589832 name="rom-rb" created_at=2013-06-01 22:03:54 UTC updated_at=2019-04-03 14:36:48 UTC>
```

## Handlers

Request and response handlers can be registered via `ROM::HTTP::Handlers` object:

``` ruby
ROM::HTTP::Handlers.register(:my_handlers,
  request: MyRequestHandler,
  response: MyResponseHandler
)
```

Then you can use `:my_handlers` when setting up a gateway.

^INFO
  Your custom handlers must be compatible with the required interface. Refer to [the built-in JSON handlers](https://github.com/rom-rb/rom-http/blob/main/lib/rom/http/handlers/json.rb) to get the idea.
^

## Learn more

* [API documentation](https://api.rom-rb.org/rom-http/)
