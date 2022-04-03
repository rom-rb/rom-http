# frozen_string_literal: true
RSpec.describe ROM::HTTP::Commands::Delete do
  include_context "setup"

  let(:relation) do
    Class.new(ROM::HTTP::Relation) do
      schema(:users) do
        attribute :id, ROM::Types::Integer
      end

      def by_id(id)
        with_params(id: id)
      end
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
      uri: uri,
      headers: headers,
      request_handler: request_handler,
      response_handler: response_handler,
      base_path: :users,
      request_method: :delete
    )
  end

  before do
    configuration.register_relation(relation)
    configuration.register_command(command)

    allow(request_handler).to receive(:call).and_return(response)
    allow(response_handler).to receive(:call).and_return(tuples)
  end

  subject! { container.commands[:users].delete.call }

  it do
    expect(request_handler).to have_received(:call).with(dataset)
    expect(response_handler).to have_received(:call).with(response, dataset)
    is_expected.to eq(tuple)
  end
end
