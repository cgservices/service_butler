RSpec.describe ServiceButler::GraphQLService do
  it 'can connect a custom query backend' do
    class FakeExampleService
      def all
        [ {id: 1}, {id: 2} ]
      end
    end

    class ExampleService < ServiceButler::GraphQLService
      host 'http://localhost:3002/graphql'
      batch_action 'examples'
    end

    ExampleService.query_backend = FakeExampleService.new

    expect(ExampleService.all).to match_array([ {id: 1}, {id: 2} ])
  end
end
