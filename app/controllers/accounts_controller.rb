class AccountsController < ApplicationController
  def balance
    render json: { balance: current_user.account.balance.amount }
  end
end
