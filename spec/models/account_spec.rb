require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'validations' do
    let(:user) { User.create(email: "test@example.com", password: "pass123") }

    it 'is invalid when balance_in_cents is less than 0' do
      account = Account.new(balance_in_cents: -1, user:)
      expect(account).not_to be_valid
      expect(account.errors[:balance_in_cents]).to include("must be greater than or equal to 0")
    end

    it 'is valid when balance_in_cents is equal to 0' do
      account = Account.new(balance_in_cents: 0, user:)
      expect(account).to be_valid
    end

    it 'is valid when balance_in_cents is greater than 0' do
      account = Account.new(balance_in_cents: 100, user:)
      expect(account).to be_valid
    end
  end
end
