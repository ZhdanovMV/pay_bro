module Api
  module V1
    class AccountsController < ApplicationController
      def balance
        render json: { balance: current_user.account.balance.amount }
      end

      def deposit
        result = DepositMoneyService.new(user: current_user, amount: params[:amount]).call

        if result[:success]
          render json: result.slice(:message, :balance)
        else
          render json: { error: result[:error] }, status: infer_status(result[:error])
        end
      end

      def withdraw
        result = WithdrawMoneyService.new(user: current_user, amount: params[:amount]).call

        if result[:success]
          render json: result.slice(:message, :balance)
        else
          render json: { error: result[:error] }, status: infer_status(result[:error])
        end
      end

      def transfer
        result = TransferMoneyService.new(
          from_user: current_user,
          recipient_email: params[:recipient_email],
          amount: params[:amount]
        ).call

        if result[:success]
          render json: result.slice(:message, :balance)
        else
          render json: { error: result[:error] }, status: infer_status(result[:error])
        end
      end

      private

      def infer_status(error)
        case error
        when "Invalid amount"
          :bad_request
        when "Recipient not found"
          :not_found
        when "Insufficient balance"
          :unprocessable_entity
        else
          :internal_server_error
        end
      end
    end
  end
end
