# frozen_string_literal: true

RSpec.describe ServiceButler::BaseService do
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
    allow(GraphQL::Client).to receive(:load_schema).with(ServiceButler::Utilities::GraphQLAdapter).and_return(GraphQL::Client.load_schema(Schema))
  end

  it 'initializes' do
    mock_schema

    class ExampleGraphqlService < ServiceButler::BaseService
      host 'http://localhost:3002/graphql'
      action 'version'
      batch_action 'versions'
    end

    expect(ExampleGraphqlService.type).to be(VersionType)
  end

  it 'can reload an object from Marshal' do
    mock_schema

    class ExampleGraphqlService < ServiceButler::BaseService
      host 'http://localhost:3002/graphql'
      action 'version'
    end

    allow(ExampleGraphqlService.adapter).to receive(:execute).and_return('data' => {'version' => {'number' => 1}})

    record = ExampleGraphqlService.find(1)

    expect{ Marshal.dump(record) }.not_to raise_exception

    dumped_record = Marshal.load(Marshal.dump(record))

    expect(dumped_record.number).to eq(1)
  end

  describe 'Auth' do
    before do
      ENV['CG_MASTER_KEY'] = 'EXAMPLEKEY'
    end

    it 'should set the CG auth token header' do
      mock_schema
      class ExampleGraphqlService < ServiceButler::BaseService
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

  describe 'type' do
    describe 'schema' do
      context 'when the config `fail_connection_silently` is false' do
        it 'raises a connection error' do
          ServiceButler.configure { |config| config.fail_connection_silently = false }

          connection_error = Errno::ECONNREFUSED.new('Connection refused')
          allow(GraphQL::Client).to receive(:load_schema).and_raise(connection_error)

          adapter = OpenStruct.new
          allow(ServiceButler::BaseService).to receive(:adapter) { adapter }

          expect { ServiceButler::BaseService.fetch_type_from_schema('version') }.to raise_exception(connection_error)
        end
      end

      context 'when the config `fail_connection_silently` is true' do
        it 'does not raise a connection error' do
          ServiceButler.configure { |config| config.fail_connection_silently = true }

          connection_error = Errno::ECONNREFUSED.new('Connection refused')
          allow(GraphQL::Client).to receive(:load_schema).and_raise(connection_error)

          adapter = OpenStruct.new
          allow(ServiceButler::BaseService).to receive(:adapter) { adapter }

          expect { ServiceButler::BaseService.fetch_type_from_schema('version') }.not_to raise_exception
        end
      end
    end
  end

  describe '#select' do
    it 'defines the selection' do
      mock_schema

      class ExampleGraphqlService < ServiceButler::BaseService
        host 'http://localhost:3002/graphql'
        action 'version'
      end

      allow(ExampleGraphqlService.adapter).to receive(:execute).and_return('data' => {'version' => {'value' => 12, 'number' => 1}})

      expect(ExampleGraphqlService.select(:number).find(1)).not_to be(nil)

      expect{ExampleGraphqlService.select(:number).find(1).value}.to raise_exception
      expect{ExampleGraphqlService.select(:value, :number).find(1).value}.not_to raise_exception
    end
  end

  describe '#find' do
    it 'fetches a single record' do
      mock_schema

      class ExampleGraphqlService < ServiceButler::BaseService
        host 'http://localhost:3002/graphql'
        action 'version'
      end

      allow(ExampleGraphqlService.adapter).to receive(:execute).and_return('data' => {'version' => {'number' => 1}})

      expect(ExampleGraphqlService.find(1)).not_to be(nil)
      expect(ExampleGraphqlService.find(1).number).to eq(1)
    end

    context 'on failure' do
      it 'returns nil' do
        expect(ServiceButler::BaseService.find(1)).to be_nil
      end
    end
  end

  describe '#find_by' do
    context 'on failure' do
      it 'returns nil' do
        expect(ServiceButler::BaseService.find_by(id: 1)).to be_nil
      end
    end
  end

  describe '#where' do
    it 'fetches a batch record' do
      class ExampleGraphqlService < ServiceButler::BaseService
        host 'http://localhost:3002/graphql'
        batch_action 'versions'
      end

      allow(ExampleGraphqlService.adapter).to receive(:execute).and_return('data' => {'versions' => [{'number' => 1}]})

      expect { ExampleGraphqlService.where(number: 1) }.not_to raise_exception
      expect(ExampleGraphqlService.where(number: 1).size).to eq(1)
    end

    context 'on failure' do
      it 'returns an empty array' do
        expect(ServiceButler::BaseService.where(id: 1)).to eq([])
      end
    end
  end

  describe '#all' do
    context 'on failure' do
      it 'returns an empty array' do
        expect(ServiceButler::BaseService.all).to eq([])
      end
    end
  end

  describe 'QueryBuilder' do
    describe '#build_request_params' do
      it 'Converts string values' do
        query = ServiceButler::Query.new(:id, variables: {number: 'ABCD123'})

        expect(ServiceButler::BaseService.new.build_request_params(query.variables)).to eq("number: \"ABCD123\"")
      end
    end
  end
end
