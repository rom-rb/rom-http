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

  describe '#primary_key' do
    subject { relation.primary_key }

    context 'with no primary key defined in schema' do
      it 'defaults to :id' do
        is_expected.to eq(:id)
      end
    end

    context 'with primary key defined in schema' do
      context 'without alias' do
        let(:relation_klass) do
          Class.new(ROM::HTTP::Relation) do
            schema do
              attribute :id, ROM::Types::Strict::Int
              attribute :name, ROM::Types::Strict::String.meta(primary_key: true)
            end
          end
        end

        it 'returns the attribute name of the primary key' do
          is_expected.to eq(:name)
        end
      end

      context 'with alias' do
        let(:relation_klass) do
          Class.new(ROM::HTTP::Relation) do
            schema do
              attribute :id, ROM::Types::Strict::Int.meta(primary_key: true, alias: :ident)
              attribute :name, ROM::Types::Strict::String
            end
          end
        end

        it 'returns the attribute name of the primary key' do
          is_expected.to eq(:ident)
        end
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
    subject { relation.to_a }

    context 'with standard schema' do
      let(:relation_klass) do
        Class.new(ROM::HTTP::Relation) do
          schema do
            attribute :id, ROM::Types::Strict::Int
          end
        end
      end

      it 'applies the schema and returns the materialized results' do
        is_expected.to match_array([
          { id: 1 },
          { id: 2 }
        ])
      end
    end

    context 'with aliased schema' do
      let(:relation_klass) do
        Class.new(ROM::HTTP::Relation) do
          schema do
            attribute :id, ROM::Types::Strict::Int
            attribute :name, ROM::Types::Strict::String.meta(alias: :username)
          end
        end
      end

      it 'applies the schema and returns the materialized results' do
        is_expected.to match_array([
          { id: 1, username: 'John' },
          { id: 2, username: 'Jill' }
        ])
      end
    end
  end

  %i[insert update].each do |method_name|
    describe "##{method_name}" do
      subject { relation.send(method_name, name: 'John') }

      before do
        allow(dataset).to receive(method_name).and_return(data)
      end

      context 'with standard schema' do
        let(:relation_klass) do
          Class.new(ROM::HTTP::Relation) do
            schema do
              attribute :id, ROM::Types::Strict::Int
            end
          end
        end

        context 'when respond with single tuple' do
          let(:data) { { id: 1, name: 'John' } }

          it 'applies the schema and returns the materialized results' do
            is_expected.to eq(id: 1)
          end
        end

        context 'when respond with multiple tuples' do
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

          it 'applies the schema and returns the materialized results' do
            is_expected.to match_array([
              { id: 1 },
              { id: 2 }
            ])
          end
        end
      end

      context 'with aliased schema' do
        let(:relation_klass) do
          Class.new(ROM::HTTP::Relation) do
            schema do
              attribute :id, ROM::Types::Strict::Int
              attribute :name, ROM::Types::Strict::String.meta(alias: :username)
            end
          end
        end

        context 'when respond with single tuple' do
          let(:data) { { id: 1, name: 'John' } }

          it 'applies the schema and returns the materialized results' do
            is_expected.to eq(id: 1, username: 'John')
          end
        end

        context 'when respond with multiple tuples' do
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

          it 'applies the schema and returns the materialized results' do
            is_expected.to match_array([
              { id: 1, username: 'John' },
              { id: 2, username: 'Jill' }
            ])
          end
        end
      end
    end
  end
end
