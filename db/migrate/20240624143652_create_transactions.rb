class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.datetime :datetime_of_transaction
      t.string :operation
      t.string :symbol
      t.decimal :amount
      t.decimal :price
      t.decimal :net_value
      t.decimal :fees
      t.decimal :total_value
      t.references :user, null: false, foreign_key: true
      t.references :wallet, null: false, foreign_key: true

      t.timestamps
    end
  end
end
