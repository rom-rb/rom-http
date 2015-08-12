RSpec.describe ROM::HTTP::Commands::Delete do
  let(:uri) { 'http://localhost:3000' }
  let(:headers) { { accept: 'application/json' } }
  let(:rom) { ROM::Environment.new }
  let(:container) { rom.finalize.env }
  let(:request_handler) { double(Proc) }
  let(:response_handler) { double(Proc) }
  let(:relation) do
    Class.new(ROM::HTTP::Relation) do
      dataset :users
    end
  end
  let(:response) { double }
  let(:tuple) { double }
  let(:tuples) { double(first: tuple) }
  let(:command) do
    Class.new(ROM::HTTP::Commands::Delete) do
      register_as :delete
      relation :users
      result :one
    end
  end
  let(:dataset) do
    ROM::HTTP::Dataset.new(
      {
        uri: uri,
        headers: headers,
        request_handler: request_handler,
        response_handler: response_handler,
        name: :users
      },
      request_method: :delete
    )
  end

  before do
    rom.setup(
      :http,
      uri: uri,
      headers: headers,
      request_handler: request_handler,
      response_handler: response_handler
    )
  end

  before do
    rom.register_relation(relation)
    rom.register_command(command)

    allow(request_handler).to receive(:call).and_return(response)
    allow(response_handler).to receive(:call).and_return(tuples)
  end

  subject! { container.command(:users).delete.call }

  it do
    expect(request_handler).to have_received(:call).with(dataset)
    expect(response_handler).to have_received(:call).with(response, dataset)
    is_expected.to eq(tuple)
  end
end
