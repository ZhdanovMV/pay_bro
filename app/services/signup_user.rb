class SignupUser
  def initialize(email:, password:)
    @user = User.new(email:, password:)
    @account = Account.new(user:, balance_in_cents: 0)
  end

  def call
    ActiveRecord::Base.transaction do
      user.save!
      account.save!
    end

    success_response
  rescue ActiveRecord::RecordInvalid => _e
    failure(user.errors.full_messages + account.errors.full_messages)
  end

  private

  attr_reader :user, :account

  def success_response
    { success: true, message: "User signup successful", user:, account: }
  end

  def failure(error)
    { success: false, error: error }
  end
end
