RSpec.shared_context 'setup' do
  let(:setup) do
    ROM.setup(
      :http,
      uri: 'http://localhost:3000',
      request_handler: request_handler,
      response_handler: response_handler
    )
  end
  let(:request_handler) { double(Proc) }
  let(:response_handler) { double(Proc) }
end
