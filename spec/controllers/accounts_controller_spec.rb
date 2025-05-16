require 'rails_helper'

RSpec.describe AccountsController, type: :controller do
  include JwtHandler

  let(:user) { create(:user) }
  let(:token) { encode_jwt({ user_id: user.id }) }

  before do
    request.headers['Authorization'] = "Bearer #{token}"
  end

  describe 'GET #balance' do
    it 'returns the current user balance' do
      get :balance
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['balance'].to_d).to eq(user.account.balance.amount)
    end
  end
end
