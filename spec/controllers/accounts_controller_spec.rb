require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  include JwtHandler

  let(:user) { create(:user) }
  let(:account) { user.account }
  let(:token) { encode_jwt({ user_id: user.id }) }

  before do
    request.headers['Authorization'] = "Bearer #{token}"
  end

  describe 'GET #balance' do
    it 'returns the current user balance' do
      get :balance
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['balance'].to_money).to eq(account.balance)
    end
  end

  describe 'POST #deposit' do
    let(:amount) { 100 }

    it 'increases the user account balance by the specified amount' do
      initial_balance = account.balance
      post :deposit, params: { amount: amount }

      expect(account.reload.balance).to eq(initial_balance + amount.to_money)
    end

    it 'returns the updated balance in the response' do
      post :deposit, params: { amount: amount }
      parsed_response = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(parsed_response['balance'].to_money).to eq(account.reload.balance)
    end
  end

  describe 'POST #withdraw' do
    let(:amount) { 50 }

    context 'when the account has sufficient balance' do
      before { account.update!(balance: account.balance + 100.to_money) }

      it 'reduces the user account balance by the specified amount' do
        initial_balance = account.balance
        post :withdraw, params: { amount: amount }

        expect(account.reload.balance).to eq(initial_balance - amount.to_money)
      end

      it 'returns the updated balance in the response' do
        post :withdraw, params: { amount: amount }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(parsed_response['balance'].to_money).to eq(user.account.reload.balance)
      end
    end

    context 'when the account has insufficient balance' do
      let(:amount) { account.balance.amount + 100 }

      it 'does not update the account balance' do
        initial_balance = account.balance
        post :withdraw, params: { amount: amount }

        expect(account.reload.balance).to eq(initial_balance)
      end

      it 'returns an error message in the response' do
        post :withdraw, params: { amount: amount }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response['error']).to eq('Insufficient balance')
      end
    end

    context 'when the amount is 0 or less' do
      let(:amount) { 0 }

      it 'does not update the account balance' do
        initial_balance = account.balance
        post :withdraw, params: { amount: amount }

        expect(account.reload.balance).to eq(initial_balance)
      end

      it 'returns a bad request status with an error message' do
        post :withdraw, params: { amount: amount }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:bad_request)
        expect(parsed_response['error']).to eq('Invalid amount')
      end
    end
  end

  describe 'POST #transfer' do
    let(:recipient) { create(:user).account }
    let(:amount) { 50 }

    context 'when sufficient balance' do
      before { account.update!(balance: account.balance + 100.to_money) }

      it 'deducts the amount from sender account and adds it to recipient account' do
        initial_sender_balance = account.balance
        initial_recipient_balance = recipient.balance

        post :transfer, params: { recipient_email: recipient.user.email, amount: amount }

        expect(account.reload.balance).to eq(initial_sender_balance - amount.to_money)
        expect(recipient.reload.balance).to eq(initial_recipient_balance + amount.to_money)
      end

      it 'returns the updated sender balance in the response' do
        post :transfer, params: { recipient_email: recipient.user.email, amount: amount }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(parsed_response['balance'].to_money).to eq(account.reload.balance)
      end
    end

    context 'when amount is 0 or less' do
      let(:amount) { 0 }

      it 'does not update any account balance' do
        initial_sender_balance = account.balance
        initial_recipient_balance = recipient.balance

        post :transfer, params: { recipient_id: recipient.id, amount: amount }

        expect(account.reload.balance).to eq(initial_sender_balance)
        expect(recipient.reload.balance).to eq(initial_recipient_balance)
      end

      it 'returns a bad request status with an error message' do
        post :transfer, params: { recipient_email: recipient.user.email, amount: amount }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:bad_request)
        expect(parsed_response['error']).to eq('Invalid amount')
      end
    end

    context 'when the recipient is not found' do
      it 'does not update the sender account balance' do
        initial_sender_balance = account.balance

        post :transfer, params: { recipient_email: "invalid email", amount: amount }

        expect(account.reload.balance).to eq(initial_sender_balance)
      end

      it 'returns a not found status with an error message' do
        post :transfer, params: { recipient_email: "invalid email", amount: amount }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(parsed_response['error']).to eq('Recipient not found')
      end
    end
  end
end
