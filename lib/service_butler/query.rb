module ServiceButler
  class Query
    SCOPE_SINGLE = :single.freeze
    SCOPE_SET = :set.freeze

    def initialize(*selection, variables: {}, scope: SCOPE_SINGLE, headers: {})
      @scope = scope
      @selection = selection
      @variables = variables
      @headers = headers
    end

    def scope=(value)
      @scope = value
    end

    def scope
      @scope
    end

    def variables=(value)
      @variables = value
    end

    def variables
      @variables
    end

    def headers=(value)
      @headers = value
    end

    def headers
      @headers
    end

    def selection=(value)
      @selection = value
    end

    def selection
      @selection
    end

    def root_selection
      @selection.flat_map { |v| v.is_a?(Hash) ? v.keys.map(&:to_s) : v.to_s }
    end
  end
end
