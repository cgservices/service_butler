RSpec.describe ServiceButler::BaseService do
  describe '#find' do
    context 'on failure' do
      it 'returns nil' do
        expect(ServiceButler::BaseService.find(1)).to be_nil
      end
    end
  end

  describe '#find_by' do
    context 'on failure' do
      it 'returns nil' do
        expect(ServiceButler::BaseService.find_by(id: 1)).to be_nil
      end
    end
  end

  describe '#where' do
    context 'on failure' do
      it 'returns an empty array' do
        expect(ServiceButler::BaseService.where(id: 1)).to eq([])
      end
    end
  end

  describe '#all' do
    context 'on failure' do
      it 'returns an empty array' do
        expect(ServiceButler::BaseService.all).to eq([])
      end
    end
  end
end
