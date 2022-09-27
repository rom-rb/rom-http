# frozen_string_literal: true

RSpec.shared_context "setup" do
  let(:configuration) do
    ROM::Configuration.new(
      :http,
      uri: uri,
      request_handler: request_handler,
      response_handler: response_handler,
      headers: headers
    )
  end
  let(:container) { ROM.container(configuration) }
  let(:rom) { container }
  let(:gateway) { container.gateways.fetch(:default) }
  let(:uri) { "http://localhost:3000" }
  let(:request_handler) { double(Proc, freeze: self) }
  let(:response_handler) { double(Proc, freeze: self) }
  let(:headers) { {accept: "application/json"} }
end
