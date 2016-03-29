class AddQuantityToInventoryItems < ActiveRecord::Migration
  def change
    add_column :inventory_items, :quantity, :integer
  end
end
