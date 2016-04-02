class AddItemAndStockSheetReferencesToFinancesPayments < ActiveRecord::Migration
  def change
    add_reference :finances_payments, :inventory_item, index: true, foreign_key: true
    add_reference :finances_payments, :inventory_stock_sheet, index: true, foreign_key: true
  end
end
