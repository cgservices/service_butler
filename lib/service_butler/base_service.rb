# frozen_string_literal: true

module ServiceButler
  class BaseService
    include Utilities::ServiceConfiguration
    include Utilities::QueryMethods

    def self.query_backend=(backend)
      @query_backend = backend
    end

    def self.query_backend
      @query_backend ||= Utilities::QueryBackend.new(configuration)
    end

    def self.configuration
      {
        host: host,
        type: type,
        adapter: adapter,
        action: action,
        batch_action: batch_action,
        query_type: query_type
      }
    end
  end
end
