# frozen_string_literal: true

RSpec.describe ServiceButler::GraphQLService do
  VersionType = GraphQL::ObjectType.define do
    name 'Version'
    field :number, types.Int
  end

  QueryType = GraphQL::ObjectType.define do
    name 'Query'
    field :version, VersionType
    field :versions, types[VersionType]
  end

  Schema = GraphQL::Schema.define(query: QueryType)

  def mock_schema
    allow(ServiceButler::GraphQLService).to receive(:schema).and_return(GraphQL::Client.load_schema(Schema))
  end

  it 'initializes' do
    mock_schema

    class ExampleGraphqlService < ServiceButler::GraphQLService
      host 'http://localhost:3002/graphql'
      action 'version'
      batch_action 'versions'
    end

    expect(ExampleGraphqlService.type).to be(VersionType)
  end

  it 'validates the initial settings' do
    mock_schema

    expect do
      class ExampleGraphqlService < ServiceButler::GraphQLService
        host 'http://localhost:3002/graphql'
        action 'not_available'
        batch_action 'not_available'
      end
    end.to raise_exception(ArgumentError)
  end

  it 'fetches a single record' do
    mock_schema

    class ExampleGraphqlService < ServiceButler::GraphQLService
      host 'http://localhost:3002/graphql'
      action 'version'
    end

    allow(ExampleGraphqlService.adapter).to receive(:execute).and_return('data' => {'version' => {'number' => 1}})

    expect(ExampleGraphqlService.find(1)).not_to be(nil)
    expect(ExampleGraphqlService.find(1).number).to eq(1)
  end

  it 'Converts string values' do
    mock_schema

    class ExampleGraphqlService < ServiceButler::GraphQLService
      host 'http://localhost:3002/graphql'
      action 'version'
    end

    allow(ExampleGraphqlService.adapter).to receive(:execute).and_return('data' => {'version' => {'number' => 'ABCD123'}})
    expect(ExampleGraphqlService).to receive(:build_query_string).with('number:"ABCD123"')
    ExampleGraphqlService.find_by(number: 'ABCD123')
  end

  it 'can reload an object from Marshal' do
    mock_schema

    class ExampleGraphqlService < ServiceButler::GraphQLService
      host 'http://localhost:3002/graphql'
      action 'version'
    end

    allow(ExampleGraphqlService.adapter).to receive(:execute).and_return('data' => {'version' => {'number' => 1}})

    record = ExampleGraphqlService.find(1)

    expect{ Marshal.dump(record) }.not_to raise_exception

    dumped_record = Marshal.load(Marshal.dump(record))

    expect(dumped_record.number).to eq(1)
  end

  it 'fetches a batch record' do
    class ExampleGraphqlService < ServiceButler::GraphQLService
      host 'http://localhost:3002/graphql'
      batch_action 'versions'
    end

    allow(ExampleGraphqlService.adapter).to receive(:execute).and_return('data' => {'versions' => [{'number' => 1}]})

    expect { ExampleGraphqlService.where(number: 1) }.not_to raise_exception
    expect(ExampleGraphqlService.where(number: 1).size).to eq(1)
  end

  it 'builds a valid query' do
    mock_schema
    class ExampleGraphqlService < ServiceButler::GraphQLService
      host 'http://localhost:3002/graphql'
      action 'version'
      batch_action 'versions'
    end

    query = ExampleGraphqlService.send(:build_query_string, 'id:1')
    expect { GraphQL.parse(query) }.not_to raise_exception
  end

  describe 'Auth' do
    before do
      ENV['CG_MASTER_KEY'] = 'EXAMPLEKEY'
    end

    it 'should set the CG auth token header' do
      mock_schema
      class ExampleGraphqlService < ServiceButler::GraphQLService
        host 'http://localhost:3002/graphql'
        action 'version'
        batch_action 'versions'
      end

      expect(ExampleGraphqlService.adapter.headers({})).to eq({'X-CG-AUTH-Token' => ENV['CG_MASTER_KEY']})
    end

    after do
      ENV['CG_MASTER_KEY'] = nil
    end
  end

  describe '#schema' do
    context 'when the config `fail_connection_silently` is false' do
      it 'raises a connection error' do
        ServiceButler.configure { |config| config.fail_connection_silently = false }

        connection_error = Errno::ECONNREFUSED.new('Connection refused')
        allow(GraphQL::Client).to receive(:load_schema).and_raise(connection_error)

        adapter = OpenStruct.new
        allow(ServiceButler::GraphQLService).to receive(:adapter) { adapter }

        expect { ServiceButler::GraphQLService.schema }.to raise_exception(connection_error)
      end
    end

    context 'when the config `fail_connection_silently` is true' do
      it 'does not raise a connection error' do
        ServiceButler.configure { |config| config.fail_connection_silently = true }

        connection_error = Errno::ECONNREFUSED.new('Connection refused')
        allow(GraphQL::Client).to receive(:load_schema).and_raise(connection_error)

        adapter = OpenStruct.new
        allow(ServiceButler::GraphQLService).to receive(:adapter) { adapter }

        expect { ServiceButler::GraphQLService.schema }.not_to raise_exception
      end
    end
  end
end
