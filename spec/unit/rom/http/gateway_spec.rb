require 'rom/lint/spec'

RSpec.describe ROM::HTTP::Gateway do
  include_context 'users and tasks'

  it_behaves_like 'a rom gateway' do
    let(:identifier) { :http }

    let(:gateway) { ROM::HTTP::Gateway }

    let(:options) do
      {
        uri: 'http://localhost:3000',
        request_handler: request_handler,
        response_handler: response_handler
      }
    end
  end

  describe '#dataset?' do
    it 'returns true if a table exists' do
      expect(gateway.dataset?(:users)).to be(true)
    end

    it 'returns false if a table does not exist' do
      expect(gateway.dataset?(:not_here)).to be(false)
    end
  end

  describe '#dataset' do
    subject { gateway.dataset(:name) }

    context 'when extended' do
      let(:gateway) { Test::Gateway.new(uri: 'test') }

      before do
        module Test
          class Gateway < ROM::HTTP::Gateway; end
        end
      end

      context 'when no Dataset defined in the same namespace' do
        it 'returns ROM::HTTP::Dataset' do
          is_expected.to be_kind_of(ROM::HTTP::Dataset)
        end
      end

      context 'when Dataset defined in the same namespace' do
        before do
          module Test
            class Dataset < ROM::HTTP::Dataset; end
          end
        end

        it 'returns ROM::HTTP::Dataset' do
          is_expected.to be_kind_of(Test::Dataset)
        end
      end
    end

    context 'when not extended' do
      let(:gateway) { ROM::HTTP::Gateway.new(uri: 'test') }

      it 'returns ROM::HTTP::Dataset' do
        is_expected.to be_kind_of(ROM::HTTP::Dataset)
      end
    end
  end
end
