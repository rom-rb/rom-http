RSpec.describe ROM::HTTP::Relation do
  let(:relation_klass) do
    Class.new(ROM::HTTP::Relation) do
      schema do
        attribute :id, ROM::Types::Strict::Int
        attribute :name, ROM::Types::Strict::String
      end
    end
  end
  let(:relation) { relation_klass.new(dataset) }
  let(:dataset) { ROM::HTTP::Dataset.new({ name: 'test' }, {}) }
  let(:data) do
    [
      {
        id: 1,
        name: 'John'
      },
      {
        id: 2,
        name: 'Jill'
      }
    ]
  end

  before do
    allow(dataset).to receive(:response).and_return(data)
  end

  describe '#initialize' do
    context 'when initialized without a schema defined' do
      let(:relation_klass) do
        Class.new(ROM::HTTP::Relation)
      end

      it do
        expect { relation }.to raise_error(::ROM::HTTP::SchemaNotDefinedError)
      end
    end
  end

  describe '#project' do
    subject { relation.project(:id).to_a }

    it 'returns the projected data' do
      is_expected.to match_array([
        { id: 1 },
        { id: 2 }
      ])
    end
  end

  describe '#exclude' do
    subject { relation.exclude(:id).to_a }

    it 'returns the data with specified keys excluded' do
      is_expected.to match_array([
        { name: 'John' },
        { name: 'Jill' }
      ])
    end
  end

  describe '#rename' do
    subject { relation.rename(id: :identity).to_a }

    it 'returns the data with keys renamed according to mapping' do
      is_expected.to match_array([
        { name: 'John', identity: 1 },
        { name: 'Jill', identity: 2 }
      ])
    end
  end

  describe '#prefix' do
    subject { relation.prefix('user').to_a }

    it 'returns the data with prefixed keys' do
      is_expected.to match_array([
        { user_id: 1, user_name: 'John' },
        { user_id: 2, user_name: 'Jill' }
      ])
    end
  end

  describe '#wrap' do
    context 'when called without a prefix' do
      subject { relation.wrap.to_a }

      it 'returns the data with keys prefixed by dataset name' do
        is_expected.to match_array([
          { test_id: 1, test_name: 'John' },
          { test_id: 2, test_name: 'Jill' }
        ])
      end
    end

    context 'when called with a prefix' do
      subject { relation.wrap('user').to_a }

      it 'returns the data with keys prefixed by the given prefix' do
        is_expected.to match_array([
          { user_id: 1, user_name: 'John' },
          { user_id: 2, user_name: 'Jill' }
        ])
      end
    end
  end

  describe '#to_a' do
    let(:relation_klass) do
      Class.new(ROM::HTTP::Relation) do
        schema do
          attribute :id, ROM::Types::Strict::Int
        end
      end
    end

    subject { relation.to_a }

    it 'applies the schema and returns the materialized results' do
      is_expected.to match_array([
        { id: 1 },
        { id: 2 }
      ])
    end
  end
end
