RSpec.describe ROM::HTTP::Relation do
  describe '#initialize' do
    let(:relation) { relation_klass.new(dataset) }
    let(:dataset) { ROM::HTTP::Dataset.new(nil, {}) }

    context 'when relation has schema' do
      let(:relation_klass) do
        Class.new(ROM::HTTP::Relation) do
          schema do
            attribute 'id', ROM::Types::Strict::Int
          end
        end
      end

      it 'sets the dataset response transformer' do
        expect(relation.dataset.response_transformer)
          .to be_a(ROM::HTTP::Dataset::ResponseTransformers::Schemad)
      end
    end

    context 'when relation does not have schema' do
      let(:relation_klass) do
        Class.new(ROM::HTTP::Relation)
      end

      it 'keeps the default (schemaless) transformer' do
        expect(relation.dataset.response_transformer)
          .to be_a(ROM::HTTP::Dataset::ResponseTransformers::Schemaless)
      end
    end
  end
end
