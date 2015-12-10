RSpec.describe ROM::HTTP::Dataset::ResponseTransformers::Schemad do
  let(:transformer) { ROM::HTTP::Dataset::ResponseTransformers::Schemad.new(schema) }
  let(:schema) do
    ROM::Plugins::Relation::Schema::Schema.create do
      attribute :id, 'form.int'
      attribute :name, 'strict.string'
      attribute :active, 'form.bool'
    end
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

    subject! { transformer.call(response, dataset) }

    context 'with no projections' do
      let(:projections) { [] }

      it do
        is_expected.to eq([
          id: 1,
          name: 'Jill',
          active: true
        ])
      end
    end

    context 'with projections' do
      let(:projections) { [:id, :name, :active] }

      it do
        is_expected.to eq([
          id: 1,
          name: 'Jill',
          active: true
        ])
      end
    end
  end
end
