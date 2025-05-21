require "rails_helper"

RSpec.describe WithdrawMoney do
  let(:user) { create(:user) }
  let(:account) { user.account }
  let(:amount) { 50.to_money }

  before do
    account.update!(balance: 100.to_money)
  end

  subject(:service) { described_class.new(user: user, amount: amount) }

  describe "#call" do
    context "when the withdrawal is successful" do
      it "reduces the account balance by the specified amount" do
        expect(service.call[:success]).to be true
        expect(account.reload.balance).to eq(50.to_money)
      end
    end

    context "when the withdrawal amount exceeds the account balance" do
      let(:amount) { 200.to_money }

      it "does not update the account balance and sets an error" do
        result = service.call
        expect(result[:success]).to be false
        expect(result[:error]).to eq("Insufficient balance")
        expect(account.reload.balance).to eq(100.to_money)
      end
    end

    context "when the withdrawal amount is invalid" do
      let(:amount) { -10.to_money }

      it "fails with an invalid amount error" do
        result = service.call
        expect(result[:success]).to be false
        expect(result[:error]).to eq("Invalid amount")
      end
    end
  end
end
