module ServiceButler
  module Utilities
    class QueryBackend

      attr_accessor :configuration
      attr_accessor :query_builder

      delegate :build_query_string, :query, to: :query_builder

      def initialize(configuration)
        @configuration = configuration
        @query_builder = Utilities::QueryBuilder.new(configuration)
      end

      def select(*args)
        query.selection = args

        self
      end

      def find(*args)
        find!(*args)
      rescue StandardError
        nil
      end

      def find!(*args)
        raise ArgumentError, 'no `action` is set for this service' if configuration[:action].nil?
        raise ArgumentError, 'Hash and Array are not supported for find!' if args.first.is_a?(Hash) || args.first.is_a?(Array)
        id = args.first

        query.scope = Query::SCOPE_SINGLE
        query.variables = {id: id}
        fetch
      end

      def find_by(*args)
        find_by!(*args)
      rescue StandardError
        nil
      end

      def find_by!(*args)
        raise ArgumentError, 'no `action` is set for this service' if configuration[:action].nil?
        raise ArgumentError, 'args given should be an Hash' unless args.first.is_a?(Hash)

        query.scope = Query::SCOPE_SINGLE
        query.variables = query.variables.merge(args.first)
        fetch
      end

      def where(*args)
        where!(*args)
      rescue StandardError
        []
      end

      def where!(*args)
        raise ArgumentError, 'no `batch_action` is set for this service' if configuration[:batch_action].nil?
        raise ArgumentError, 'args given should be an Hash' unless args.first.is_a?(Hash)

        query.scope = Query::SCOPE_SET
        query.variables = query.variables.merge(args.first)
        fetch
      end

      def all(*args)
        all!(*args)
      rescue StandardError
        []
      end

      def all!(*_args)
        raise ArgumentError, 'no `batch_action` is set for this service' if configuration[:batch_action].nil?

        query.scope = Query::SCOPE_SET
        fetch
      end

      def fetch
        document = GraphQL.parse(build_query_string)
        response = configuration[:adapter].execute(document: document, context: {'headers' => query.headers})

        raise StandardError, "Failed to retrieve data; #{response['errors']}" if response['errors']

        if(query.scope == Query::SCOPE_SINGLE)
          Response.new(query.root_selection, response['data'][configuration[:action]])
        elsif(query.scope == Query::SCOPE_SET)
          response['data'][configuration[:batch_action]].map do |item|
            Response.new(query.root_selection, item)
          end
        else
          raise StandardError, 'Unknown scope given'
        end
      end
    end
  end
end
