class ChangeChangeToDifferenceOnInventoryStockSheets < ActiveRecord::Migration
  def change
    rename_column :inventory_stock_sheets, :quantity_change, :quantity_difference
    rename_column :inventory_stock_sheets, :unit_value_change, :unit_value_difference
    rename_column :inventory_stock_sheets, :total_value_change, :total_value_difference
  end
end
