module Api
  module V1
    class AccountsController < ApplicationController
      def balance
        render json: { balance: current_user.account.balance.amount }
      end

      def deposit
        result = DepositMoney.new(user: current_user, amount: deposit_params[:amount]).call

        if result[:success]
          render json: result.slice(:message, :balance)
        else
          render json: { error: result[:error] }, status: infer_status(result[:error])
        end
      end

      def withdraw
        result = WithdrawMoney.new(user: current_user, amount: withdraw_params[:amount]).call

        if result[:success]
          render json: result.slice(:message, :balance)
        else
          render json: { error: result[:error] }, status: infer_status(result[:error])
        end
      end

      def transfer
        result = TransferMoney.new(
          from_user: current_user,
          recipient_email: transfer_params[:recipient_email],
          amount: transfer_params[:amount]
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

      def deposit_params
        params.permit(:amount)
      end

      def withdraw_params
        params.permit(:amount)
      end

      def transfer_params
        params.permit(:amount, :recipient_email)
      end
    end
  end
end
