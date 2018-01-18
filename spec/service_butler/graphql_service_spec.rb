require "byebug"

RSpec.describe ServiceButler::GraphQLService do
  VersionType = GraphQL::ObjectType.define do
    name "Version"
    field :number, types.Int
  end

  QueryType = GraphQL::ObjectType.define do
    name "Query"
    field :version, VersionType
    field :versions, types[VersionType]
  end

  Schema = GraphQL::Schema.define(query: QueryType)

  before :each do
    allow(ServiceButler::GraphQLService).to receive(:schema).and_return(GraphQL::Client.load_schema(Schema))
  end

  it "initializes" do
    class ExampleGraphqlService < ServiceButler::GraphQLService
      host 'http://localhost:3002/graphql'
      action 'version'
      batch_action 'versions'
    end

    expect(ExampleGraphqlService.type).to be(VersionType)
  end

  it "validates the initial settings" do
    expect {
      class ExampleGraphqlService < ServiceButler::GraphQLService
        host 'http://localhost:3002/graphql'
        action 'not_available'
        batch_action 'not_available'
      end
    }.to raise_exception(ArgumentError)

  end

  it "fetches a single record" do
    class ExampleGraphqlService < ServiceButler::GraphQLService
      host 'http://localhost:3002/graphql'
      action 'version'
      batch_action 'versions'
    end

    allow(ServiceButler::GraphQLService).to receive(:fetch).and_return({'data' => {'version' => {'number' => 1}}})

    expect(ExampleGraphqlService.find(1)).not_to be(nil)
    expect(ExampleGraphqlService.find(1).number).to eq(1)
  end

  it "builds a valid query" do
    class ExampleGraphqlService < ServiceButler::GraphQLService
      host 'http://localhost:3002/graphql'
      action 'version'
      batch_action 'versions'
    end

    query = ExampleGraphqlService.send(:build_query_string, "id:1")
    expect{ GraphQL.parse(query) }.not_to raise_exception
  end
end