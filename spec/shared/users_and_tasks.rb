RSpec.shared_context 'users and tasks' do
  include_context 'setup'
  let(:users_relation) do
    Class.new(ROM::HTTP::Relation) do
      dataset :users

      def by_id(id)
        with_params(id: id)
      end
    end
  end
  let(:tasks_relation) do
    Class.new(ROM::HTTP::Relation) do
      dataset :tasks

      def by_id(id)
        with_params(id: id)
      end
    end
  end

  before do
    configuration.register_relation(users_relation)
    configuration.register_relation(tasks_relation)
  end
end
