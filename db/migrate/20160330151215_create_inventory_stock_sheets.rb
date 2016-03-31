class CreateInventoryStockSheets < ActiveRecord::Migration
  def change
    create_table :inventory_stock_sheets do |t|
      t.references :inventory_item, index: true, foreign_key: true
      t.integer :quantity
      t.integer :quantity_change
      t.decimal :unit_value
      t.decimal :unit_value_change
      t.decimal :total_value
      t.decimal :total_value_change
      t.string :currency

      t.timestamps null: false
    end
  end
end
