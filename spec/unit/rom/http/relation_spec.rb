RSpec.describe ROM::HTTP::Relation do
  subject(:relation) { relation_klass.new(dataset) }

  let(:relation_klass) do
    Class.new(ROM::HTTP::Relation) do
      schema do
        attribute :id, ROM::Types::Int.meta(primary_key: true)
        attribute :name, ROM::Types::String
      end
    end
  end

  let(:dataset) { ROM::HTTP::Dataset.new(uri: 'test') }

  let(:data) do
    [{ id: 1, name: 'John' }, { id: 2, name: 'Jill' }]
  end

  before do
    allow(dataset).to receive(:response).and_return(data)
    relation.schema.finalize_attributes!
  end

  describe '#primary_key' do
    it 'returns configured primary key name' do
      expect(relation.primary_key).to be(:id)
    end

    it 'returns nil when primary key was not defined' do
      relation = Class.new(ROM::HTTP::Relation) { schema {} }.new([])
      expect(relation.primary_key).to be(nil)
    end
  end

  describe '#project' do
    it 'returns the projected data' do
      expect(relation.project(:id).to_a).to eql([{ id: 1 }, { id: 2 }])
    end
  end

  describe '#exclude' do
    subject { relation.exclude(:id).to_a }

    it 'returns the data with specified keys excluded' do
      expect(relation.exclude(:id).to_a).to eql([{ name: 'John' }, { name: 'Jill' }])
    end
  end

  describe '#rename' do
    subject { relation.rename(id: :identity).to_a }

    it 'returns the data with keys renamed according to mapping' do
      expect(relation.rename(id: :identity).to_a)
        .to eql([{ name: 'John', identity: 1 }, { name: 'Jill', identity: 2 }])
    end
  end

  describe '#prefix' do
    it 'returns the data with prefixed keys' do
      expect(relation.prefix('user').to_a)
        .to match_array([{ user_id: 1, user_name: 'John' }, { user_id: 2, user_name: 'Jill' }])
    end
  end

  describe '#to_a' do
    context 'with standard schema' do
      let(:relation_klass) do
        Class.new(ROM::HTTP::Relation) do
          schema do
            attribute :id, ROM::Types::Strict::Int
          end
        end
      end

      it 'applies the schema and returns the materialized results' do
        expect(relation.to_a).to eql([{ id: 1 }, { id: 2 }])
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
        expect(relation.to_a).to eql([{ id: 1, username: 'John' }, { id: 2, username: 'Jill' }])
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
              attribute :name, ROM::Types::Strict::String
            end
          end
        end

        context 'when respond with single tuple' do
          let(:data) { { id: 1, name: 'John' } }

          it 'applies the schema and returns the materialized results' do
            is_expected.to eq(id: 1, name: 'John')
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
              { id: 1, name: 'John' },
              { id: 2, name: 'Jill' }
            ])
          end
        end
      end
    end
  end
end
