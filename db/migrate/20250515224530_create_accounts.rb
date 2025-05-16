class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.integer :balance_in_cents, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
