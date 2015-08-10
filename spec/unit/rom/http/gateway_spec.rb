require 'rom/lint/spec'

RSpec.describe ROM::HTTP::Gateway do
  include_context 'users and tasks'

  let(:gateway) { rom.gateways[:default] }

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
    # H4xz0rz
    let(:uri) { options }
  end

  describe '#dataset?' do
    it 'returns true if a table exists' do
      expect(gateway.dataset?(:users)).to be(true)
    end

    it 'returns false if a table does not exist' do
      expect(gateway.dataset?(:not_here)).to be(false)
    end
  end

  describe 'required config' do
    it 'errors if config does not meet requirements' do
      expect { ROM::HTTP::Gateway.new({}) }.to raise_error(ROM::HTTP::GatewayConfigurationError)
    end
  end
end
