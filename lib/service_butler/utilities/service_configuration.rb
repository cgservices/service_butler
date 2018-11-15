module ServiceButler
  module Utilities
    module ServiceConfiguration
      def self.included base
        base.extend ClassMethods
      end

      module ClassMethods
        def host(url = nil)
          if url
            @host = url
          else
            @host
          end
        end

        def type
          @type ||= begin
            schema_type = fetch_type_from_schema( action || batch_action )

            case schema_type
              when GraphQL::NonNullType, GraphQL::ListType
                schema_type.of_type
              when GraphQL::ObjectType
                schema_type
              else
                raise "Unable to load type" unless ServiceButler.configuration.fail_connection_silently?
                nil
            end
          end
        end

        def adapter
          @adapter ||= Utilities::GraphQLAdapter.new(@host.to_s)
        end

        def action(action = nil)
          if action
            @action = action
          else
            @action
          end
        end

        def batch_action(batch_action = nil)
          if batch_action
            @batch_action = batch_action
          else
            @batch_action
          end
        end

        def query_type(query_type = nil)
          if query_type
            @query_type = query_type
          else
            @query_type
          end
        end

        def fetch_type_from_schema(type)
          schema = GraphQL::Client.load_schema(adapter)

          schema_type = schema.types[type]

          unless schema_type
            raise StandardError, 'Query(type) not defined in schema' unless schema.types['Query']
            raise ArgumentError, "Field '#{type}' not found in query type" unless schema.types['Query'].fields[type]

            schema_type = schema.types['Query'].fields[type].type
          end

          schema_type
        rescue => e
          raise e unless ServiceButler.configuration.fail_connection_silently?
        end
      end
    end
  end
end
