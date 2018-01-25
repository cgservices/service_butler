# frozen_string_literal: true

module ServiceButler
  module Utilities
    class GraphQLAdapter < ::GraphQL::Client::HTTP
      def headers(context)
        context['headers'] || {}
      end
    end
  end
end
