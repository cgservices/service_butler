module ServiceButler
  module Utilities
    module QueryBuilder
      def query
        @query ||= Query.new(*default_query_fields)
      end

      def default_query_fields
        type.fields.reject do |_key, field|
          if field.type.respond_to?(:of_type)
            field.type.of_type.is_a? GraphQL::ObjectType
          else
            field.type.is_a? GraphQL::ObjectType
          end
        end.keys
      end

      def build_query_string
        self.class.type(build_request_action(query.scope)) if type.nil?
        return '' unless type

        <<-GRAPHQL
          {
            #{build_request_action(query.scope)}(#{build_request_params(query.variables)}){
              #{build_request_fields(query.selection)}
            }
          }
        GRAPHQL
      end

      def build_request_action(scope)
        scope == Query::SCOPE_SET ? self.class.batch_action : self.class.action
      end

      def build_request_params(params)
        return if (params.respond_to?(:empty?) ? !!params.empty? : !params)

        param_strings = params.map do |key, value|
          "#{key}: #{build_request_argument(value)}"
        end

        param_strings.join(', ')
      end

      def build_request_argument(argument)
        case argument
          when Numeric
            argument.to_s
          when Array
            "[#{argument.map{ |v| build_request_argument(v) }.join(', ')}]"
          when NilClass
            'null'
          else
            "\"#{argument}\""
        end
      end

      def build_request_fields(fieldset)
        return "#{fieldset}" unless fieldset.respond_to?(:map)

        field_strings = fieldset.map do |field|
          case field
            when Hash
              field.map { |k, v| "#{k} { #{build_request_fields(v)} }" }
            else
              "#{field}"
          end
        end

        field_strings.join(', ')
      end
    end
  end
end