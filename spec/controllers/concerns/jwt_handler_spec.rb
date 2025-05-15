require 'rails_helper'

RSpec.describe JwtHandler, type: :concern do
  let(:dummy_class) do
    Class.new do
      include JwtHandler
    end
  end

  let(:instance) { dummy_class.new }
  let(:payload) { { email: 'user@example.com' } }
  let(:secret_key) { 'test_secret_key' }
  let(:token) { JWT.encode(payload, secret_key, 'HS256') }

  describe '#encode_jwt' do
    it 'encodes a payload into a JWT' do
      result = instance.encode_jwt(payload, secret_key:)
      decoded_payload = JWT.decode(result, secret_key, true, algorithm: 'HS256')[0]
      expect(decoded_payload.symbolize_keys).to eq(payload)
    end
  end

  describe '#decode_jwt' do
    context 'when token is valid' do
      it 'decodes the JWT and returns the payload' do
        result = instance.decode_jwt(token, secret_key:)
        expect(result.symbolize_keys).to eq(payload)
      end
    end

    context 'when token is invalid' do
      let(:invalid_token) { 'invalid.token.string' }

      it 'returns nil' do
        result = instance.decode_jwt(invalid_token, secret_key:)
        expect(result).to be_nil
      end
    end

    context 'when token is expired' do
      let(:expired_payload) { { user_id: 1, exp: 1.hour.ago.to_i } }
      let(:expired_token) { JWT.encode(expired_payload, secret_key, 'HS256') }

      it 'returns nil' do
        result = instance.decode_jwt(expired_token, secret_key:)
        expect(result).to be_nil
      end
    end
  end
end
