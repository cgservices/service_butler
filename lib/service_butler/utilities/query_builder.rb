module ServiceButler
  module Utilities
    module QueryBuilder
      def query
        @query ||= Query.new(*default_query_fields)
      end

      def default_query_fields
        return [] unless type
        type.fields.reject do |_key, field|
          if field.type.respond_to?(:of_type)
            field.type.of_type.is_a? GraphQL::ObjectType
          else
            field.type.is_a? GraphQL::ObjectType
          end
        end.keys
      end

      def build_query_string
        self.class.type if type.nil?

        <<-GRAPHQL
          {
            #{build_request_action(query.scope)}(#{build_request_params(query.variables)}){
              #{build_request_fields(query.selection, query.variables)}
            }
          }
        GRAPHQL
      end

      def build_request_action(scope)
        request_action = scope == Query::SCOPE_SET ? self.class.batch_action : self.class.action

        raise "No action is set for scope '#{scope}'" unless request_action

        request_action
      end

      def build_request_params(params)
        return if (params.respond_to?(:empty?) ? !!params.empty? : !params)

        param_strings = params.except(:__param).map do |key, value|
          case value
            when Hash
              value[:__param] ? "#{key}: #{build_request_argument(value[:__param])}" : ''
            else
              "#{key}: #{build_request_argument(value)}"
          end
        end

        param_strings.reject(&:empty?).join(', ')
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

      def build_request_fields(fieldset, params = {})
        return "#{fieldset}" unless fieldset.respond_to?(:map)

        field_strings = fieldset.map do |field|
          case field
            when Hash
              field.map do |k, v|
                sub_params = params[k] || {}
                "#{k}(#{build_request_params(sub_params)}) { #{build_request_fields(v, sub_params)} }"
              end
            else
              "#{field}"
          end
        end

        field_strings.join(', ')
      end
    end
  end
end