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

  let(:dataset) { instance_double(ROM::HTTP::Dataset, response: data, map: data) }

  let(:data) do
    [{ id: 1, name: 'John' }, { id: 2, name: 'Jill' }]
  end

  describe '#primary_key' do
    before do
      relation.schema.finalize_attributes!
    end

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

  describe "#insert" do
    let(:result) do
      relation.insert(name: 'John')
    end

    context 'with single tuple' do
      let(:data) { { id: 1, name: 'John' } }

      it 'applies the schema and returns the materialized results' do
        expect(dataset).to receive(:insert).and_return(data)
        expect(result).to eql(id: 1, name: 'John')
      end
    end

    context 'with many tuples' do
      let(:data) do
        [{ id: 1, name: 'John' }, { id: 2, name: 'Jill' }]
      end

      it 'applies the schema and returns the materialized results' do
        expect(dataset).to receive(:insert).and_return(data)
        expect(result).to eql([{ id: 1, name: 'John' }, { id: 2, name: 'Jill' }])
      end
    end
  end

  describe "#update" do
    let(:result) do
      relation.update(name: 'John')
    end

    context 'with single tuple' do
      let(:data) { { id: 1, name: 'John' } }

      it 'applies the schema and returns the materialized results' do
        expect(dataset).to receive(:update).and_return(data)
        expect(result).to eql(id: 1, name: 'John')
      end
    end

    context 'with many tuples' do
      let(:data) do
        [{ id: 1, name: 'John' }, { id: 2, name: 'Jill' }]
      end

      it 'applies the schema and returns the materialized results' do
        expect(dataset).to receive(:update).and_return(data)
        expect(result).to eql([{ id: 1, name: 'John' }, { id: 2, name: 'Jill' }])
      end
    end
  end

  describe "#delete" do
    let(:result) do
      relation.delete
    end

    it 'forwards to its dataset' do
      expect(dataset).to receive(:delete).and_return(data)
      expect(relation.delete).to eql(data)
    end
  end
end
