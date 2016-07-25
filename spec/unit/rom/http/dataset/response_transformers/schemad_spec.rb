RSpec.describe ROM::HTTP::Dataset::ResponseTransformers::Schemad do
  subject(:transformer) { ROM::HTTP::Dataset::ResponseTransformers::Schemad.new(schema) }

  let(:schema) do
    { id: ROM::Types::Form::Int,
      name: ROM::Types::Strict::String,
      active: ROM::Types::Form::Bool }
  end

  describe '#call' do
    let(:response) do
      [
        {
          id: '1',
          name: 'Jill',
          email: 'jill@fakemail.com',
          active: 'true'
        }
      ]
    end
    let(:dataset) do
      double('ROM::HTTP::Dataset', projections: projections)
    end

    context 'with no projections' do
      let(:projections) { [] }

      it 'returns original tuples' do
        result = transformer.call(response, dataset)

        expect(result).to eql([id: 1, name: 'Jill', active: true])
      end
    end

    context 'with projections' do
      let(:projections) { [:id, :name, :active] }

      it 'returns projected relation tuples' do
        result = transformer.call(response, dataset)

        expect(result).to eql([id: 1, name: 'Jill', active: true])
      end
    end
  end
end
