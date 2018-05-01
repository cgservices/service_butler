# frozen_string_literal: true

module ServiceButler
  class BaseService
    class << self
      def find(*args)
        find!(*args)
      rescue StandardError
        nil
      end

      def find!(*_args)
        raise StandardError, 'find! method not implemented'
      end

      def find_by(*args)
        find_by!(*args)
      rescue StandardError
        nil
      end

      def find_by!(*_args)
        raise StandardError, 'find_by! method not implemented'
      end

      def where(*args)
        where!(*args)
      rescue StandardError
        []
      end

      def where!(*_args)
        raise StandardError, 'where! method not implemented'
      end

      def all(*args)
        all!(*args)
      rescue StandardError
        []
      end

      def all!
        raise StandardError, 'all! method not implemented'
      end
    end
  end
end
