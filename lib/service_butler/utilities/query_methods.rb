module ServiceButler
  module Utilities
    module QueryMethods
      def self.included base
        base.extend ClassMethods
      end

      module ClassMethods
        def select(*args)
          query_backend.select(*args)
        end

        def find(*args)
          query_backend.find(*args)
        end

        def find!(*args)
          query_backend.find!(*args)
        end

        def find_by(*args)
          query_backend.find_by(*args)
        end

        def find_by!(*args)
          query_backend.find_by!(*args)
        end

        def where(*args)
          query_backend.where(*args)
        end

        def where!(*args)
          query_backend.where!(*args)
        end

        def all(*args)
          query_backend.all(*args)
        end

        def all!(*args)
          query_backend.all!(*args)
        end
      end
    end
  end
end
