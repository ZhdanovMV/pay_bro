require "rails_helper"

RSpec.describe DepositMoneyService do
  let(:user) { create(:user) }
  let(:account) { user.account }
  let(:amount) { 100.to_money }

  subject(:service) { described_class.new(user: user, amount: amount) }

  describe "#call" do
    context "when the deposit is successful" do
      it "increases the account balance by the deposit amount" do
        initial_balance = account.balance
        expect(service.call[:success]).to be_truthy
        expect(account.reload.balance).to eq(initial_balance + amount)
      end
    end

    context "when the deposit amount is invalid" do
      let(:amount) { -10.to_money }

      it "fails with an invalid deposit amount error" do
        result = service.call
        expect(result[:success]).to be_falsey
        expect(result[:error]).to eq("Invalid amount")
        expect(account.reload.balance).to eq(account.balance)
      end
    end
  end
end
