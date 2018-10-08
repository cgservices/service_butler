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

      def execute(document:, operation_name: nil, variables: {}, context: {})
        request = Net::HTTP::Post.new(uri.request_uri)

        request.basic_auth(uri.user, uri.password) if uri.user || uri.password

        request["Accept"] = "application/json"
        request["Content-Type"] = "application/json"
        headers(context).each { |name, value| request[name] = value }

        body = {}
        body["query"] = document.to_query_string
        body["variables"] = variables if variables.any?
        body["operationName"] = operation_name if operation_name
        request.body = JSON.generate(body)

        response = connection.request(request)

        raise StandardError.new "Connection to #{uri} failed. Response class: #{response.class}; Response code: #{response.code}" if response.code == '401'

        case response
        when Net::HTTPOK, Net::HTTPBadRequest
          JSON.parse(response.body)
        else
          { "errors" => [{ "message" => "#{response.code} #{response.message}" }] }
        end
      end

    end
  end
end
