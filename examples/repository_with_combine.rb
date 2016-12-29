# NOTE: This does not work at the moment

require 'inflecto'
require 'json'
require 'uri'
require 'net/http'
require 'rom-repository'

class RequestHandler
  def call(dataset)
    uri = URI(dataset.uri)
    uri.path = dataset.absolute_path
    uri.query = URI.encode_www_form(dataset.params)

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
    Array([JSON.parse(response.body, symbolize_names: true)]).flatten
  end
end

class Users < ROM::Relation[:http]
  schema(:users) do
    attribute :id, ROM::Types::Int.meta(primary_key: true)
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

class Posts < ROM::Relation[:http]
  schema(:posts) do
    attribute :id, ROM::Types::Int.meta(primary_key: true)
    attribute :userId, ROM::Types::Int.meta(alias: :user_id)
    attribute :title, ROM::Types::String
    attribute :body, ROM::Types::String
  end

  def by_id(id)
    with_path(id.to_s)
  end

  def for_user(user)
    with_options(
      base_path: 'users',
      path: "#{user.first[:id]}/posts"
    )
  end
end

class UserRepository < ROM::Repository[:users]
  relations :posts

  def find_with_posts(user_id)
    users.by_id(user_id).combine_children(many: posts.for_user).first
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
configuration.register_relation(Posts)
container = ROM.container(configuration)

UserRepository.new(container).find_with_posts(1)
# Dry::Struct::Error: [ROM::Struct[Post].new] :userId is missing in Hash input
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/dry-struct-0.1.1/lib/dry/struct/class_interface.rb:80:in `rescue in new'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/dry-struct-0.1.1/lib/dry/struct/class_interface.rb:74:in `new'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/transproc-0.4.1/lib/transproc/class.rb:30:in `constructor_inject'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/transproc-0.4.1/lib/transproc/function.rb:47:in `call'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/transproc-0.4.1/lib/transproc/function.rb:47:in `call'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/transproc-0.4.1/lib/transproc/array.rb:50:in `block in map_array!'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/transproc-0.4.1/lib/transproc/array.rb:50:in `map!'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/transproc-0.4.1/lib/transproc/array.rb:50:in `map_array!'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/transproc-0.4.1/lib/transproc/array.rb:41:in `map_array'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/transproc-0.4.1/lib/transproc/function.rb:47:in `call'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/transproc-0.4.1/lib/transproc/function.rb:47:in `call'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/transproc-0.4.1/lib/transproc/hash.rb:270:in `map_value'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/transproc-0.4.1/lib/transproc/function.rb:47:in `call'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/transproc-0.4.1/lib/transproc/function.rb:47:in `call'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/transproc-0.4.1/lib/transproc/composite.rb:30:in `call'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/transproc-0.4.1/lib/transproc/array.rb:50:in `block in map_array!'
# ... 12 levels...
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/bundler/gems/rom-5b338e873884/lib/rom/relation/materializable.rb:20:in `to_a'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/bundler/gems/rom-5b338e873884/lib/rom/relation/materializable.rb:62:in `first'
#   from (irb):72:in `find_with_posts'
#   from (irb):88
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/bundler-1.12.2/lib/bundler/cli/console.rb:15:in `run'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/bundler-1.12.2/lib/bundler/cli.rb:333:in `console'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/bundler-1.12.2/lib/bundler/vendor/thor/lib/thor/command.rb:27:in `run'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/bundler-1.12.2/lib/bundler/vendor/thor/lib/thor/invocation.rb:126:in `invoke_command'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/bundler-1.12.2/lib/bundler/vendor/thor/lib/thor.rb:359:in `dispatch'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/bundler-1.12.2/lib/bundler/vendor/thor/lib/thor/base.rb:440:in `start'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/bundler-1.12.2/lib/bundler/cli.rb:11:in `start'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/bundler-1.12.2/exe/bundle:27:in `block in <top (required)>'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/bundler-1.12.2/lib/bundler/friendly_errors.rb:98:in `with_friendly_errors'
#   from /home/andy/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/bundler-1.12.2/exe/bundle:19:in `<top (required)>'
#   from /home/andy/.rbenv/versions/2.3.0/bin/bundle:23:in `load'
#   from /home/andy/.rbenv/versions/2.3.0/bin/bundle:23:in `<main>'irb(main):089:0>
