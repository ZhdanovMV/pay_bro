class AccountsController < ApplicationController
  def balance
    render json: { balance: current_user.account.balance.amount }
  end

  def deposit
    deposit_money = params[:amount].to_money
    account = current_user.account

    account.with_lock do
      account.balance += deposit_money
      account.save!
    end

    render json: { balance: account.balance }
  end

  def withdraw
    withdrawal_money = params[:amount].to_money
    account = current_user.account

    return render json: { error: "Invalid amount" }, status: :bad_request if withdrawal_money.amount <= 0

    success = false

    account.with_lock do
      if account.balance >= withdrawal_money
        account.balance -= withdrawal_money
        account.save!
        success = true
      end
    end

    if success
      render json: { balance: account.balance }
    else
      render json: { error: "Insufficient balance" }, status: :unprocessable_entity
    end
  end
end
