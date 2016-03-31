class AddTotalQuantityToInventoryItems < ActiveRecord::Migration
  def change
    add_column :inventory_items, :total_quantity, :integer
  end
end
