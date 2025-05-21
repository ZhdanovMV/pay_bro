require 'rails_helper'

RSpec.describe SignupUser do
  describe '#call' do
    let(:service) { described_class.new(email: 'test@example.com', password: 'pass123') }

    context 'with valid parameters' do
      it 'creates a new User' do
        expect { service.call }.to change(User, :count).by(1)
      end

      it 'creates a new Account' do
        expect { service.call }.to change(Account, :count).by(1)
      end

      it 'associates the User with the Account' do
        result = service.call

        expect(result[:user]).to be_persisted
        expect(result[:account]).to be_persisted
        expect(result[:user].account).to eq(result[:account])
      end
    end

    context 'when invalid data is provided' do
      let(:service) { described_class.new(email: '', password: '') }

      it 'does not create a User' do
        expect { service.call }.not_to change(User, :count)
      end

      it 'does not create an Account' do
        expect { service.call }.not_to change(Account, :count)
      end

      it 'returns an error' do
        result = service.call
        expect(result[:success]).to be(false)
        expect(result[:error]).to be_present
      end
    end
  end
end
