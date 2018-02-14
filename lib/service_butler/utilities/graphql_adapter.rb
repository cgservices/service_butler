# frozen_string_literal: true

module ServiceButler
  module Utilities
    class GraphQLAdapter < ::GraphQL::Client::HTTP
      def headers(context)
        headers = {}
        headers.merge!({'X-CG-AUTH-Token' => ENV['CG_MASTER_KEY']}) if ENV['CG_MASTER_KEY']
        headers.merge!(context['headers']) if context['headers']
        headers
      end
    end
  end
end
