require 'rails_helper'

RSpec.describe TransferMoneyService do
  let(:user) { create(:user) }
  let(:recipient) { create(:user) }
  let(:amount) { 100.to_money }

  subject(:service) { described_class.new(from_user: user, recipient_email: recipient.email, amount: amount) }

  describe "#call" do
    context "when the transfer is successful" do
      before do
        user.account.update(balance: 200.to_money)
        recipient.account.update(balance: 50.to_money)
      end

      it "transfers the amount" do
        expect(service.call[:success]).to be_truthy
        expect(user.account.reload.balance).to eq(100.to_money)
        expect(recipient.account.reload.balance).to eq(150.to_money)
      end
    end

    context "when the transfer fails due to insufficient balance" do
      before { user.account.update(balance: 50.to_money) }

      it "does not transfer the amount" do
        result = service.call
        expect(result[:success]).to be_falsey
        expect(result[:error]).to eq("Insufficient balance")
        expect(user.account.reload.balance).to eq(50.to_money)
        expect(recipient.account.reload.balance).to eq(0.to_money)
      end
    end

    context "when the recipient is not found" do
      subject(:service) { described_class.new(from_user: user, recipient_email: "nonexistent@email.com", amount: amount) }

      it "returns an error" do
        result = service.call
        expect(result[:success]).to be_falsey
        expect(result[:error]).to eq("Recipient not found")
      end
    end

    context "when the amount is invalid" do
      let(:amount) { -10.to_money }

      it "returns an error" do
        result = service.call
        expect(result[:success]).to be_falsey
        expect(result[:error]).to eq("Invalid amount")
      end
    end
  end
end
