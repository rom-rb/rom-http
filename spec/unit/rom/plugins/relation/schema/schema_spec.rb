RSpec.describe ROM::Plugins::Relation::Schema::Schema do
  let(:klass) { ROM::Plugins::Relation::Schema::Schema }
  let(:schema) do
    klass.create do
      attribute :id, 'form.int'
      attribute :name, 'strict.string'
      attribute :active, 'form.bool'
    end
  end

  describe '#attribute_names' do
    subject! { schema.attribute_names }

    it { is_expected.to match_array([:id, :name, :active])}
  end

  describe '#apply' do
    let(:attributes) do
      {
        id: '1',
        name: 'John',
        active: 'true'
      }
    end

    subject! { schema.apply(attributes) }

    it { is_expected.to eq(id: 1, name: 'John', active: true) }
  end
end
