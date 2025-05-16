class AccountsController < ApplicationController
  def balance
    render json: { balance: current_user.account.balance.amount }
  end

  def deposit
    deposit_money = params[:amount].to_money
    account = current_user.account

    account.with_lock do
      account.update!(balance: account.balance + deposit_money)
    end

    render json: { balance: account.balance.amount }
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
