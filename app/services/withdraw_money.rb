class WithdrawMoney
  def initialize(user:, amount:)
    @user = user
    @amount = amount.to_money
    @success = false
  end

  def call
    return failure("Invalid amount") if amount <= 0

    account = user.account

    account.with_lock do
      if account.balance >= amount
        account.update!(balance: account.balance - amount)
        @success = true
      end
    end

    if success
      success_response(account)
    else
      failure("Insufficient balance")
    end
  end

  private

  attr_reader :user, :amount, :success

  def success_response(account)
    { success: true, message: "Withdrawal successful", balance: account.balance.amount }
  end

  def failure(error)
    { success: false, error: error }
  end
end
