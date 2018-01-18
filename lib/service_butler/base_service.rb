module ServiceButler
  class BaseService
    @attributes = {}

    def initialize(attributes)
      @attributes = attributes
    end

    class << self
      def find(*args)
        find!(*args) rescue nil
      end

      def find!(*args)
        raise StandardError, 'find! method not implemented'
      end

      def find_by(*args)
        find_by!(*args) rescue nil
      end

      def find_by!(*args)
        raise StandardError, 'find_by! method not implemented'
      end

      def where(*args)
        raise StandardError, 'where method not implemented'
      end

      def all
        raise StandardError, 'all method not implemented'
      end
    end
  end
end