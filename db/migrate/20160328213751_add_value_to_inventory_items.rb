class AddValueToInventoryItems < ActiveRecord::Migration
  def change
    add_column :inventory_items, :starting_value, :decimal
    add_column :inventory_items, :value, :decimal
    add_column :inventory_items, :ending_value, :decimal
    add_column :inventory_items, :currency, :string
  end
end
