module ServiceButler
  class GraphQLService < BaseService
    def initialize(attributes)
      super

      define_attribute_methods
    end

    def host
      self.class.host
    end

    def type
      self.class.type
    end

    def adapter
      self.class.adapter
    end

    def schema
      self.class.schema
    end

    class << self
      # The host should always be defined first.
      # Otherwise the adapter won't be able to load
      # And then nothing can be loaded
      def host(url = nil)
        if url
          @host = url
        else
          @host
        end
      end

      def action(action = nil)
        if action
          @action = action
          type(action)
        else
          @action
        end
      end

      def batch_action(batch_action = nil)
        if batch_action
          @batch_action = batch_action
          type(batch_action) unless type
        else
          @batch_action
        end
      end

      # Type is not needed, will be called when running action.
      def type(type = nil)
        if type.is_a?(String)
          schema_type = schema.types[type]

          unless schema_type
            raise StandardError, 'Query(type) not defined in schema' unless schema.types["Query"]
            raise ArgumentError, "Field '#{type}' not found in query type" unless schema.types["Query"].fields[type]

            schema_type = schema.types["Query"].fields[type].type
          end

          raise "Type #{type} not found in schema" if schema_type.nil?
          @type = schema_type
        elsif type.is_a?(GraphQL::NonNullType)
          @type = type.of_type
        elsif type.is_a?(GraphQL::ObjectType)
          @type = type
        else
          @type
        end
      end

      def adapter
        @adapter ||= Utilities::GraphQLAdapter.new(@host)
      end

      # Retreive the schema. Cache it so it won't be called all the time
      # `Rails.cache` wont work here. However we do need it to keep everything up-to-date
      def schema
        if @schema.nil? || (@schema_cached_at + 10.minutes) < Time.now
          @schema = GraphQL::Client.load_schema(adapter)
          @schema_cached_at = Time.now
        end

        @schema
      end

      # Query methods
      def find!(*args)
        raise ArgumentError, 'no `action` is set for this service' if action.nil?
        raise ArgumentError, 'Hash and Array are not supported for find!' if args.first.is_a?(Hash) || args.first.is_a?(Array)
        id = args.first

        params = "id:#{id}"

        result = fetch(build_query_string(params))

        raise StandardError, "Failed to retrieve data; #{result['errors']}" if result['errors']

        new(result['data'][action])
      end

      def find_by!(*args)
        raise ArgumentError, 'no `action` is set for this service' if action.nil?
        raise 'Unsupported argument given. Needs to be a hash' unless args.first.is_a? Hash

        result = fetch(build_query_string(parse_params(args)))

        raise StandardError, "Failed to retrieve data; #{result['errors']}" if result['errors']

        new(result['data'][action])
      end

      def where(*args)
        raise ArgumentError, 'no `batch_action` is set for this service' if batch_action.nil?
        raise ArgumentError, 'Unsupported argument given. Needs to be a hash' unless args.first.is_a? Hash

        result = fetch(build_query_string(parse_params(args), true))

        raise StandardError, "Failed to retrieve data; #{result['errors']}" if result['errors']

        result['data'][batch_action].map do |item|
          new(item)
        end
      end

      def all
        raise ArgumentError, 'no `batch_action` is set for this service' if batch_action.nil?
        result = fetch(build_query_string('', true))

        raise StandardError, "Failed to retrieve data; #{result['errors']}" if result['errors']

        result['data'][batch_action].map do |item|
          new(item)
        end
      end

      private
      def fetch(graphql_string)
        context = {}
        context['headers'] = {'X-CG-AUTH-Token' => ENV['CG_MASTER_KEY']} if ENV['CG_MASTER_KEY']
        document = GraphQL.parse(graphql_string)
        adapter.execute(document: document, context: context)
      end

      def parse_params(arguments)
        arguments.first.map do |k,v|
          value = if v.nil?
                    'null'
                  else
                    v
                  end

          "#{k}:#{value}"
        end.join(', ')
      end

      def build_query_string(params, batch = false)
        <<-GRAPHQL
          {
            #{(batch ? batch_action : action)}(#{params}){
              #{type.fields.keys.join(" ")}
            }
          }
        GRAPHQL
      end
    end

    private
    def define_attribute_methods
      type.fields.keys.each do |attribute|
        define_singleton_method(attribute) { @attributes[attribute] }
      end
    end
  end
end