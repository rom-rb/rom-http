# frozen_string_literal: true

RSpec.describe 'Associations', :vcr do
  let(:configuration) do
    configuration = ROM::Configuration.new(
      :http, {
        uri: 'https://api.mocki.io',
        headers: {
          Accept: 'application/json'
        },
        handlers: :json
      }
    )
    configuration.register_relation(users_klass)
    configuration.register_relation(posts_klass)
    ROM.container(configuration)
  end

  let(:users) { configuration.relations[:users] }

  let(:posts) { configuration.relations[:posts] }

  let(:users_klass) do
    Class.new(ROM::HTTP::Relation) do
      dataset do
        with_options(base_path: 'v1/c2037888')
      end

      schema(:users) do
        attribute :id, ROM::Types::Integer.meta(primary_key: true)
        attribute :name, ROM::Types::String

        associations do
          has_many :posts, view: :for_users, override: true
        end
      end

      def for_posts(_assoc, posts)
        # IRL, you would filter the users with post id params in the API
        _post_ids = posts.map { |u| u[:id] }
        self
      end
    end
  end

  let(:posts_klass) do
    Class.new(ROM::HTTP::Relation) do
      dataset do
        with_options(base_path: 'v1/2ac7da28')
      end

      schema(:posts) do
        attribute :id, ROM::Types::Integer.meta(primary_key: true)
        attribute :user_id, ROM::Types::Integer.meta(foreign_key: true)
        attribute :title, ROM::Types::String

        associations do
          belongs_to :user, view: :for_posts, override: true
        end
      end

      def for_users(_assoc, users)
        # IRL, you would filter the posts with user id params in the API
        _user_ids = users.map { |u| u[:id] }
        self
      end
    end
  end

  describe 'has_many' do
    it 'can combine results' do
      VCR.use_cassette(:user_with_posts) do
        result = users.combine(:posts).to_a

        expect(result).to contain_exactly(
          { id: 1, name: 'John', posts: [{ id: 1, user_id: 1, title: 'Post 1' }] },
          { id: 2, name: 'Jill', posts: [{ id: 2, user_id: 2, title: 'Post 2' }] }
        )
      end
    end
  end

  describe 'belongs_to' do
    it 'can combine results' do
      VCR.use_cassette(:posts_with_user) do
        result = posts.combine(:user).to_a

        expect(result).to contain_exactly(
          { id: 1, title: 'Post 1', user: { id: 1, name: 'John' }, user_id: 1 },
          { id: 2, title: 'Post 2', user: { id: 2, name: 'Jill' }, user_id: 2 }
        )
      end
    end
  end
end

# api.mocki.io/v1/2ac7da28
# users api.mocki.io/v1/c2037888
