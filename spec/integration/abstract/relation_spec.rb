RSpec.describe ROM::HTTP::Relation do
  subject(:users) { container.relation(:users).by_id(id).filter(params) }

  include_context 'setup'

  let(:relation) do
    Class.new(ROM::HTTP::Relation) do
      dataset :users

      def by_id(id)
        append_path(id.to_s)
      end

      def filter(params)
        with_params(params)
      end
    end
  end

  let(:response) { double }
  let(:tuples) { [] }
  let(:id) { 1337 }
  let(:params) { { filters: { first_name: 'John' } } }

  let(:dataset) do
    ROM::HTTP::Dataset.new(
      {
        uri: uri,
        headers: headers,
        request_handler: request_handler,
        response_handler: response_handler,
        name: :users
      },
      request_method: :get,
      path: "/#{id}",
      params: params
    )
  end

  before do
    configuration.register_relation(relation)

    allow(request_handler).to receive(:call).and_return(response)
    allow(response_handler).to receive(:call).and_return(tuples)
  end

  it 'returns relation tuples' do
    expect(users.to_a).to eql(tuples)

    expect(request_handler).to have_received(:call).with(dataset).once
    expect(response_handler).to have_received(:call).with(response, dataset).once
  end
end
