class CreateFinancesBalanceSheets < ActiveRecord::Migration
  def change
    create_table :finances_balance_sheets do |t|
      t.references :owner, polymorphic: true, index: true
      t.decimal :net_worth
      t.decimal :total_assets
      t.decimal :current_assets
      t.decimal :fixed_assets
      t.decimal :total_liabilities
      t.decimal :current_liabilities
      t.decimal :long_term_liabilities
      t.decimal :cash
      t.decimal :total_ledgers_receivable
      t.decimal :total_ledgers_debt
      t.decimal :total_wallets
      t.string :currency
      t.references :item, polymorphic: true, index: true
      t.string :action

      t.timestamps null: false
    end
  end
end
