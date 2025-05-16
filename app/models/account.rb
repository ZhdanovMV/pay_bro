class Account < ApplicationRecord
  belongs_to :user

  monetize :balance_in_cents, as: "balance"

  validates :balance_in_cents, numericality: { greater_than_or_equal_to: 0 }
end
