class CreateFinancesPayments < ActiveRecord::Migration
  def change
    create_table :finances_payments do |t|
      t.text :description
      t.decimal :value, null: false
      t.string :currency, null: false, default: "USD"
      t.references :wallet, index: true
      t.references :ledger, index: true
      t.decimal :wallet_balance
      t.decimal :ledger_balance

      t.timestamps null: false
    end
  end
end
