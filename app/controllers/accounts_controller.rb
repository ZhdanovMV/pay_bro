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
    withdrawal_money = params[:amount].to_money
    return render json: { error: "Invalid amount" }, status: :bad_request if withdrawal_money.amount <= 0

    account = current_user.account
    success = false

    account.with_lock do
      if account.balance >= withdrawal_money
        account.update!(balance: account.balance - withdrawal_money)
        success = true
      end
    end

    if success
      render json: { balance: account.balance.amount }
    else
      render json: { error: "Insufficient balance" }, status: :unprocessable_entity
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
