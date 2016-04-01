class AddCapitalAssetsAndInventoryToFinancesBalanceSheets < ActiveRecord::Migration
  def change
    add_column :finances_balance_sheets, :capital_assets, :decimal, null: false, default: 0
    add_column :finances_balance_sheets, :inventory, :decimal, null: false, default: 0
  end
end
