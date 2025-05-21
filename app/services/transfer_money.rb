class TransferMoney
  def initialize(from_user:, recipient_email:, amount:)
    @from_user = from_user
    @recipient_email = recipient_email
    @amount = amount.to_money
    @success = false
  end

  def call
    return failure("Invalid amount") if amount <= 0

    recipient = User.find_by(email: recipient_email)
    return failure("Recipient not found") unless recipient

    transfer_money(from_account: from_user.account, to_account: recipient.account)

    if success
      success_response(from_user.account)
    else
      failure("Insufficient balance")
    end
  end

  private

  attr_reader :from_user, :recipient_email, :amount, :success

  def transfer_money(from_account:, to_account:)
    ActiveRecord::Base.transaction do
      [ from_account, to_account ].sort_by(&:id).each(&:lock!)

      if from_account.balance >= amount
        from_account.update!(balance: from_account.balance - amount)
        to_account.update!(balance: to_account.balance + amount)
        @success = true
      end
    end
  end

  def success_response(account)
    { success: true, message: "Transfer successful", balance: account.balance.amount }
  end

  def failure(error)
    { success: false, error: error }
  end
end
