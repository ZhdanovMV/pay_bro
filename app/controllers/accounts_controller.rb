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
    transfer_money = params[:amount].to_money
    return render json: { error: "Invalid amount" }, status: :bad_request if transfer_money.amount <= 0

    recipient = User.find_by(email: params[:recipient_email])
    return render json: { error: "Recipient not found" }, status: :not_found unless recipient

    from_account = current_user.account
    to_account = recipient.account

    accounts = [ from_account, to_account ].sort_by(&:id)
    success = false

    ActiveRecord::Base.transaction do
      accounts.each { |account| account.lock! }

      if from_account.balance >= transfer_money
        from_account.update!(balance: from_account.balance - transfer_money)
        to_account.update!(balance: to_account.balance + transfer_money)
        success = true
      end
    end

    if success
      render json: { message: "Transfer successful", balance: from_account.balance.amount }
    else
      render json: { error: "Insufficient balance" }, status: :unprocessable_entity
    end
  end
end
