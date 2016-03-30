class AddConsumableAndSaleableToInventoryItems < ActiveRecord::Migration
  def change
    add_column :inventory_items, :consumable, :boolean
    add_column :inventory_items, :saleable, :boolean
  end
end
