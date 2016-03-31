class AddUnitValuesToInventoryItems < ActiveRecord::Migration
  def change
    add_column :inventory_items, :unit_starting_value, :decimal
    add_column :inventory_items, :unit_value, :decimal
    add_column :inventory_items, :unit_ending_value, :decimal
  end
end
