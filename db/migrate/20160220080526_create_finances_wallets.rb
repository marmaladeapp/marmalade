class CreateFinancesWallets < ActiveRecord::Migration
  def change
    create_table :finances_wallets do |t|
      t.string :name
      t.text :description
      t.decimal :balance
      t.decimal :starting_balance
      t.string :currency
      t.datetime :starting_date
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
