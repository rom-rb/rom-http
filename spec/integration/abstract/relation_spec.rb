require "json"
require "rom-repository"

RSpec.describe ROM::HTTP::Relation do
  subject(:users) { container.relations[:users].by_id(id).filter(query_params) }

  include_context "setup"

  let(:relation) do
    Class.new(ROM::HTTP::Relation) do
      schema(:users) do
        attribute :id, ROM::Types::Integer
        attribute :name, ROM::Types::String
      end

      def by_id(id)
        append_path(id.to_s)
      end

      def filter(params)
        with_query_params(params)
      end
    end
  end

  let(:response) { tuples.to_json }
  let(:tuples) { [{"id" => 1337, "name" => "John"}] }
  let(:id) { 1337 }
  let(:query_params) { {filters: {first_name: "John"}} }

  let(:dataset) do
    ROM::HTTP::Dataset.new(
      uri: uri,
      headers: headers,
      request_handler: request_handler,
      response_handler: response_handler,
      base_path: :users,
      path: id.to_s,
      query_params: query_params
    )
  end

  before do
    configuration.register_relation(relation)

    allow(request_handler).to receive(:call).and_return(response)
    allow(response_handler).to receive(:call).and_return(tuples)
  end

  it "returns relation tuples" do
    expect(users.to_a).to eql([id: 1337, name: "John"])

    expect(request_handler).to have_received(:call).with(dataset).once
    expect(response_handler).to have_received(:call).with(response, dataset).once
  end

  context "using a repo" do
    let(:repo) do
      Class.new(ROM::Repository) do
        def self.to_s
          "UserRepo"
        end
      end.new(container)
    end

    it "returns structs" do
      user = repo.users.by_id(1337).filter(query_params).first

      expect(user.id).to be(1337)
      expect(user.name).to eql("John")

      expect(request_handler).to have_received(:call).with(dataset).once
      expect(response_handler).to have_received(:call).with(response, dataset).once
    end
  end
end
