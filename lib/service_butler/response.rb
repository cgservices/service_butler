module ServiceButler
  class Response
    @attributes = {}
    @fields = {}

    def initialize(fields, attributes)
      @fields = fields
      @attributes = attributes
      define_attribute_methods
    end

    def marshal_dump
      [@fields, @attributes]
    end

    def marshal_load(array)
      @fields = array[0]
      @attributes = array[1]
      define_attribute_methods
    end

    def define_attribute_methods
      fields = @fields
      fields = fields.keys if fields.is_a?(Hash)

      fields.each do |field|
        define_singleton_method(field) do
          if @attributes[field].is_a?(Array)
            collection = @attributes[field].map do |attribute|
              attribute ? Response.new(attribute.keys, attribute) : nil
            end

            collection.reject(&:nil?)
          else
            @attributes[field]
          end
        end
      end
    end
  end
end
