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
    if %i(post put patch).include?(dataset.request_method)
      JSON.parse(response.body, symbolize_names: true)
    else
      Array([JSON.parse(response.body, symbolize_names: true)]).flatten
    end
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

  def find(id)
    users.by_id(id).first
  end

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
# =>
# #<ROM::Struct[User]
#   id=1
#   name="Leanne Graham"
#   username="Bret"
#   email="Sincere@april.biz"
#   phone="1-770-736-8031 x56442"
#   website="hildegard.org"
#   posts=[
#     #<ROM::Struct[Post]
#       id=1
#       user_id=1
#       title="sunt aut facere repellat provident occaecati excepturi optio reprehenderit"
#       body="quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto">,
#     #<ROM::Struct[Post]
#       id=2
#       user_id=1
#       title="qui est esse"
#       body="est rerum tempore vitae\nsequi sint nihil reprehenderit dolor beatae ea dolores neque\nfugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis\nqui aperiam non debitis possimus qui neque nisi nulla">,
#     #<ROM::Struct[Post]
#       id=3
#       user_id=1
#       title="ea molestias quasi exercitationem repellat qui ipsa sit aut"
#       body="et iusto sed quo iure\nvoluptatem occaecati omnis eligendi aut ad\nvoluptatem doloribus vel accusantium quis pariatur\nmolestiae porro eius odio et labore et velit aut">,
#     #<ROM::Struct[Post]
#       id=4
#       user_id=1
#       title="eum et est occaecati"
#       body="ullam et saepe reiciendis voluptatem adipisci\nsit amet autem assumenda provident rerum culpa\nquis hic commodi nesciunt rem tenetur doloremque ipsam iure\nquis sunt voluptatem rerum illo velit">,
#     #<ROM::Struct[Post]
#       id=5
#       user_id=1
#       title="nesciunt quas odio"
#       body="repudiandae veniam quaerat sunt sed\nalias aut fugiat sit autem sed est\nvoluptatem omnis possimus esse voluptatibus quis\nest aut tenetur dolor neque">,
#     #<ROM::Struct[Post]
#       id=6
#       user_id=1
#       title="dolorem eum magni eos aperiam quia"
#       body="ut aspernatur corporis harum nihil quis provident sequi\nmollitia nobis aliquid molestiae\nperspiciatis et ea nemo ab reprehenderit accusantium quas\nvoluptate dolores velit et doloremque molestiae">,
#     #<ROM::Struct[Post]
#       id=7
#       user_id=1
#       title="magnam facilis autem"
#       body="dolore placeat quibusdam ea quo vitae\nmagni quis enim qui quis quo nemo aut saepe\nquidem repellat excepturi ut quia\nsunt ut sequi eos ea sed quas">,
#     #<ROM::Struct[Post]
#       id=8
#       user_id=1
#       title="dolorem dolore est ipsam"
#       body="dignissimos aperiam dolorem qui eum\nfacilis quibusdam animi sint suscipit qui sint possimus cum\nquaerat magni maiores excepturi\nipsam ut commodi dolor voluptatum modi aut vitae">,
#     #<ROM::Struct[Post]
#       id=9
#       user_id=1
#       title="nesciunt iure omnis dolorem tempora et accusantium"
#       body="consectetur animi nesciunt iure dolore\nenim quia ad\nveniam autem ut quam aut nobis\net est aut quod aut provident voluptas autem voluptas">,
#     #<ROM::Struct[Post]
#       id=10
#       user_id=1
#       title="optio molestias id quia eum"
#       body="quo et expedita modi cum officia vel magni\ndoloribus qui repudiandae\nvero nisi sit\nquos veniam quod sed accusamus veritatis error">
#   ]>
