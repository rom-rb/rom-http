RSpec.describe ROM::HTTP::Commands::Update do
  include_context "setup"

  let(:relation_class) do
    Class.new(ROM::HTTP::Relation) do
      schema(:users) do
        attribute :id, ROM::Types::Integer
        attribute :first_name, ROM::Types::String
        attribute :last_name, ROM::Types::String
      end

      def by_id(id)
        with_query_params(id: id)
      end
    end
  end

  let(:relation) { container.relations[:users] }

  context "with single tuple" do
    let(:response) { double }

    let(:attributes) { {first_name: "John", last_name: "Jackson"} }

    let(:tuple) { attributes.merge(id: 1) }

    let(:command) { relation.command(:update) }

    let(:dataset) do
      ROM::HTTP::Dataset.new(
        uri: uri,
        base_path: :users,
        headers: headers,
        request_handler: request_handler,
        response_handler: response_handler,
        request_method: :put,
        body_params: attributes
      )
    end

    before do
      configuration.register_relation(relation_class)

      allow(request_handler).to receive(:call).and_return(response)
      allow(response_handler).to receive(:call).and_return(tuple)
    end

    subject! { command.call(attributes) }

    it do
      is_expected.to eq(tuple)

      expect(request_handler).to have_received(:call).with(dataset)
      expect(response_handler).to have_received(:call).with(response, dataset)
    end
  end

  context "with a collection" do
    let(:response_1) { double }

    let(:response_2) { double }

    let(:attributes_1) { {first_name: "John", last_name: "Jackson"} }

    let(:attributes_2) { {first_name: "Jill", last_name: "Smith"} }

    let(:tuple_1) { attributes_1.merge(id: 1) }

    let(:tuple_2) { attributes_2.merge(id: 2) }

    let(:attributes) { [attributes_1, attributes_2] }

    let(:command) { relation.command(:update, result: :many) }

    let(:dataset_1) do
      ROM::HTTP::Dataset.new(
        uri: uri,
        headers: headers,
        request_handler: request_handler,
        response_handler: response_handler,
        base_path: :users,
        request_method: :put,
        body_params: attributes_1
      )
    end

    let(:dataset_2) do
      ROM::HTTP::Dataset.new(
        uri: uri,
        headers: headers,
        request_handler: request_handler,
        response_handler: response_handler,
        base_path: :users,
        request_method: :put,
        body_params: attributes_2
      )
    end

    before do
      configuration.register_relation(relation_class)

      allow(request_handler).to receive(:call).and_return(response_1, response_2)
      allow(response_handler).to receive(:call).and_return(tuple_1, tuple_2)
    end

    subject! { command.call(attributes) }

    it do
      expect(request_handler).to have_received(:call).with(dataset_1)
      expect(response_handler).to have_received(:call).with(response_1, dataset_1)
      expect(request_handler).to have_received(:call).with(dataset_2)
      expect(response_handler).to have_received(:call).with(response_2, dataset_2)
      is_expected.to eq([tuple_1, tuple_2])
    end
  end
end
