require "rom/http/handlers/json"

RSpec.describe ROM::HTTP::Handlers do
  describe "JSON" do
    subject(:dataset) do
      ROM::HTTP::Dataset.new(
        uri: uri,
        request_handler: ROM::HTTP::Handlers::JSONRequest,
        response_handler: ROM::HTTP::Handlers::JSONResponse
      )
    end

    let(:uri) do
      "https://api.github.com"
    end

    it "loads an array with hashes from the response body" do
      VCR.use_cassette(:github_repos) do
        org = dataset.with_path("/orgs/rom-rb").first

        expect(org["id"]).to be(4_589_832)
        expect(org["login"]).to eql("rom-rb")
      end
    end
  end
end
