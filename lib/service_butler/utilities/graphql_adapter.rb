# frozen_string_literal: true

module ServiceButler
  module Utilities
    class GraphQLAdapter < ::GraphQL::Client::HTTP
      def headers(context)
        headers = {}

        x_cg_auth_token = ServiceButler.configuration.x_cg_auth_token
        headers.merge!({ 'X-CG-AUTH-Token' => x_cg_auth_token }) if x_cg_auth_token

        headers.merge!(context['headers']) if context['headers']
        headers
      end
    end
  end
end
