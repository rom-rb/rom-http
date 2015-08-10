describe ROM::HTTP::Commands::Delete do
  include_context 'users and tasks'

  subject(:command) { ROM::HTTP::Commands::Delete.build(users) }

  let(:users_relation_klass) do
    Class.new(ROM::HTTP::Relation) do
      dataset :users

      def by_id(id)
        with_params(id: id)
      end
    end
  end
  let(:users) { rom.relations[:users] }

  before do
    setup.register_relation(users_relation_klass)
  end

  it_behaves_like 'a command'
end
