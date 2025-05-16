class DepositMoneyService
  attr_reader :user, :amount

  def initialize(user:, amount:)
    @user = user
    @amount = amount.to_money
  end

  def call
    return failure("Invalid amount") if amount <= 0

    account = user.account

    account.with_lock do
      account.update!(balance: account.balance + amount)
    end

    success_response(account)
  end

  private

  def success_response(account)
    { success: true, message: "Deposit successful", balance: account.balance.amount }
  end

  def failure(error)
    { success: false, error: error }
  end
end
