require 'rails_helper'

RSpec.describe AuthController, type: :controller do
  describe 'POST #signup' do
    context 'with valid params' do
      let(:valid_params) do
        {
          email: 'test@example.com',
          password: 'password123'
        }
      end

      it 'creates a new user' do
        expect {
          post :signup, params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'creates a new account' do
        expect {
          post :signup, params: valid_params
        }.to change(Account, :count).by(1)
      end

      it 'returns a success response' do
        post :signup, params: valid_params
        expect(response).to have_http_status(:created)
      end

      it 'returns a JWT token as JSON' do
        post :signup, params: valid_params
        json_response = JSON.parse(response.body)
        expect(json_response['token']).to be_present
      end
    end

    context 'with invalid attributes' do
      let(:invalid_params) do
        {
          email: '',
          password: '123'
        }
      end

      it 'does not create a new user' do
        expect {
          post :signup, params: invalid_params
        }.to_not change(User, :count)
      end

      it 'does not create a new account' do
        expect {
          post :signup, params: invalid_params
        }.to_not change(Account, :count)
      end

      it 'returns an unprocessable entity status' do
        post :signup, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages as JSON' do
        post :signup, params: invalid_params
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to be_present
      end
    end
  end

  describe 'POST #login' do
    context 'with valid credentials' do
      let(:user) { create(:user) }

      let(:valid_params) do
        {
          email: user.email,
          password: 'password123'
        }
      end

      it 'returns a success response' do
        post :login, params: valid_params
        expect(response).to have_http_status(:ok)
      end

      it 'returns a JWT token as JSON' do
        post :login, params: valid_params
        json_response = JSON.parse(response.body)
        expect(json_response['token']).to be_present
      end
    end

    context 'with invalid credentials' do
      let(:invalid_params) do
        {
          email: 'unknown@example.com',
          password: 'wrongpassword'
        }
      end

      it 'returns an unauthorized status' do
        post :login, params: invalid_params
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error message as JSON' do
        post :login, params: invalid_params
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid credentials')
      end
    end
  end
end
