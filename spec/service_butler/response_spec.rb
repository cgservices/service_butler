# frozen_string_literal: true

RSpec.describe ServiceButler::Response do
  describe '#define_attribute_methods' do
    it 'does not define them when no fields are given' do
      response = ServiceButler::Response.new([], {})

      expect(response).not_to receive(:define_singleton_method)

      response.send(:define_attribute_methods)
    end

    it 'defines the attribute methods' do
      response = ServiceButler::Response.new([:id], {id: 1})

      expect(response).to receive(:define_singleton_method).with(:id)
      response.send(:define_attribute_methods)
    end
  end
end
