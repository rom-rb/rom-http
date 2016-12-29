RSpec.describe ROM::HTTP::Transformer do
  let(:klass) { ROM::HTTP::Transformer }
  let(:transformer) { klass.new }
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

  describe '#rename' do
    subject! { transformer.rename(id: :identity).call(data) }

    it 'renames the keys according to the given mapping' do
      is_expected.to match_array([
        {
          name: 'John',
          identity: 1
        },
        {
          name: 'Jill',
          identity: 2
        }
      ])
    end
  end

  describe '#prefix' do
    subject! { transformer.prefix('user').call(data) }

    context 'with symbol keys' do
      it 'prefixes the keys with the given prefix and maintains original type' do
        is_expected.to match_array([
          {
            user_id: 1,
            user_name: 'John'
          },
          {
            user_id: 2,
            user_name: 'Jill'
          }
        ])
      end
    end

    context 'with non-symbol keys' do
      let(:data) do
        [
          {
            'id' => 1,
            'name' => 'John'
          },
          {
            'id' => 2,
            'name' => 'Jill'
          }
        ]
      end

      it 'prefixes the keys with the given prefix and maintains original type' do
        is_expected.to match_array([
          {
            'user_id' => 1,
            'user_name' => 'John'
          },
          {
            'user_id' => 2,
            'user_name' => 'Jill'
          }
        ])
      end
    end
  end

  describe '#call' do
    subject! { transformer.rename(id: :identity).prefix('user').call(data) }

    it 'maps the transformations over an array of hashes' do
      is_expected.to match_array([
        {
          user_name: 'John',
          user_identity: 1
        },
        {
          user_name: 'Jill',
          user_identity: 2
        }
      ])
    end
  end
end
