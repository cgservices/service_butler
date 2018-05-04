module ServiceButler
  class Query
    SCOPE_SINGLE = :single.freeze
    SCOPE_SET = :set.freeze

    def initialize(*selection, variables: {}, scope: SCOPE_SINGLE)
      @scope = scope
      @selection = selection
      @variables = variables
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

    def selection=(value)
      @selection = value
    end

    def selection
      @selection
    end

    def root_selection
      @selection.select{|v| v.is_a?(String) || v.is_a?(Symbol) }.map(&:to_s)
    end
  end
end