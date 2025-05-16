class User < ApplicationRecord
  has_secure_password

  has_one :account, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true

  after_create :create_account

  private

  def create_account
    Account.create!(user: self, balance_in_cents: 0)
  end
end
