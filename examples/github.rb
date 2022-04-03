require "rom"

rom = ROM.container(:http, uri: "https://api.github.com", handlers: :json) do |config|
  config.relation(:orgs) do
    schema do
      attribute :id, ROM::HTTP::Types::Integer
      attribute :name, ROM::HTTP::Types::String
      attribute :created_at, ROM::HTTP::Types::Params::Time
      attribute :updated_at, ROM::HTTP::Types::Params::Time
    end

    def by_name(name)
      append_path(name)
    end
  end
end

orgs = rom.relations[:orgs]

orgs.by_name("rom-rb").one
# {:id=>4589832, :name=>"rom-rb", :created_at=>2013-06-01 22:03:54 UTC, :updated_at=>2019-04-03 14:36:48 UTC}

orgs.with(auto_struct: true).by_name("rom-rb").one
# #<ROM::Struct::Org id=4589832 name="rom-rb" created_at=2013-06-01 22:03:54 UTC updated_at=2019-04-03 14:36:48 UTC>
