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

  describe '#empty?' do
    context 'when there are no attributes' do
      it 'returns true' do
        response = ServiceButler::Response.new([], {})
        expect(response).to be_empty
      end
    end

    context 'when response attributes is nil' do
      it 'returns true' do
        response = ServiceButler::Response.new([], nil)
        expect(response).to be_empty
      end
    end

    context 'when there are attributes available' do
      it 'returns false' do
        response = ServiceButler::Response.new([], { 'attr' => true })
        expect(response).not_to be_empty
      end
    end
  end
end
