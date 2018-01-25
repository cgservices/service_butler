RSpec.describe ServiceButler::Configuration do
  describe '#fail_connection_silently?' do
    context 'when fail_connection_silently has not been configured' do
      it 'returns true' do
        expect(ServiceButler.configuration.fail_connection_silently?).to eq true
      end
    end

    context 'when fail_connection_silently is configured to false' do
      it 'returns false' do
        ServiceButler.configure { |config| config.fail_connection_silently = false }
        expect(ServiceButler.configuration.fail_connection_silently?).to eq false
      end
    end
  end
end
