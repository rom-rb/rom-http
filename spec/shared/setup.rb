RSpec.shared_context 'setup' do
  let(:env) { ROM::Environment.new }
  let(:setup) do
    env.setup(
      :http,
      uri: 'http://localhost:3000',
      request_handler: request_handler,
      response_handler: response_handler
    )
  end
  let(:rom) { setup.finalize }
  let(:request_handler) { double(Proc, freeze: self) }
  let(:response_handler) { double(Proc, freeze: self) }
end
