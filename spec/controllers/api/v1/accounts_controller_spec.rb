require 'rails_helper'

RSpec.describe Api::V1::AccountsController, type: :controller do
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
    let(:deposit_service) { instance_double(DepositMoney) }

    before do
      allow(DepositMoney).to receive(:new).and_return(deposit_service)
    end

    context "when deposit successful" do
      before do
        allow(deposit_service).to receive(:call).and_return({ success: true, message: 'Deposit successful', balance: amount })
      end

      it 'returns the success message in the response' do
        post :deposit, params: { amount: amount }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(parsed_response['message']).to eq('Deposit successful')
      end

      it 'returns the updated balance in the response' do
        post :deposit, params: { amount: amount }
        parsed_response = JSON.parse(response.body)

        expect(parsed_response['balance']).to eq(100)
      end
    end

    context "when deposit failed" do
      before do
        allow(deposit_service).to receive(:call).and_return({ success: false, error: 'Invalid amount' })
      end

      it 'returns a bad request status with an error message' do
        post :withdraw, params: { amount: 0 }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:bad_request)
        expect(parsed_response['error']).to eq('Invalid amount')
      end
    end
  end

  describe 'POST #withdraw' do
    let(:amount) { 50 }

    let(:withdraw_service) { instance_double(WithdrawMoney) }

    before do
      allow(WithdrawMoney).to receive(:new).and_return(withdraw_service)
    end

    context 'when withdrawal successful' do
      before do
        allow(withdraw_service).to receive(:call).and_return({ success: true, message: 'Withdrawal successful', balance: 100 })
      end

      it 'returns the success message in the response' do
        post :withdraw, params: { amount: amount }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(parsed_response['message']).to eq('Withdrawal successful')
      end

      it 'returns the updated balance in the response' do
        post :withdraw, params: { amount: amount }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(parsed_response['balance']).to eq(100)
      end
    end

    context 'when withdrawal failed' do
      before do
        allow(withdraw_service).to receive(:call).and_return({ success: false, error: 'Insufficient balance' })
      end

      it 'returns an error message in the response' do
        post :withdraw, params: { amount: 100 }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response['error']).to eq('Insufficient balance')
      end
    end
  end

  describe 'POST #transfer' do
    let(:recipient) { create(:user).account }
    let(:amount) { 50 }

    let(:transfer_service) { instance_double(TransferMoney) }

    before do
      allow(TransferMoney).to receive(:new).and_return(transfer_service)
    end

    context 'when transfer successful' do
      before do
        allow(transfer_service).to receive(:call).and_return({ success: true, message: 'Transfer successful', balance: 100 })
      end

      it 'returns the success message in the response' do
        post :transfer, params: { recipient_email: recipient.user.email, amount: amount }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(parsed_response['message']).to eq('Transfer successful')
      end

      it 'returns the updated sender balance in the response' do
        post :transfer, params: { recipient_email: recipient.user.email, amount: amount }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:ok)
        expect(parsed_response['balance']).to eq(100)
      end
    end

    context 'when transfer failed' do
      before do
        allow(transfer_service).to receive(:call).and_return({ success: false, error: 'Invalid amount' })
      end

      it 'returns a bad request status with an error message' do
        post :transfer, params: { recipient_email: recipient.user.email, amount: 0 }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:bad_request)
        expect(parsed_response['error']).to eq('Invalid amount')
      end
    end
  end
end
