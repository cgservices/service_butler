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

  describe '#x_cg_auth_token' do
    context 'when x_cg_auth_token has not been configured' do
      it 'defaults to nil' do
        expect(ServiceButler.configuration.x_cg_auth_token).to be_nil
      end
    end

    context 'when x_cg_auth_token is configured' do
      it 'returns the configured value' do
        ServiceButler.configure { |config| config.x_cg_auth_token = 'my-auth-token' }
        expect(ServiceButler.configuration.x_cg_auth_token).to eq 'my-auth-token'
      end
    end
  end
end
