module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_request, only: [ :signup, :login ]

      def signup
        result = SignupUser.new(email: user_params["email"], password: user_params["password"]).call

        if result[:success]
          render json: { token: encode_jwt({ user_id: result[:user].id }) }, status: :created
        else
          render json: { error: result[:error] }, status: :unprocessable_entity
        end
      end

      def login
        user = User.find_by(email: user_params[:email])

        if user&.authenticate(params[:password])
          render json: { token: encode_jwt({ user_id: user.id }) }
        else
          render json: { error: "Invalid credentials" }, status: :unauthorized
        end
      end

      private

      def user_params
        params.permit(:email, :password)
      end
    end
  end
end
