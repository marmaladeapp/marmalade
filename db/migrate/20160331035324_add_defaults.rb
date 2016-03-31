class AddDefaults < ActiveRecord::Migration
  def change
    change_column :inventory_items, :starting_value, :decimal, :default => BigDecimal.new(0)
    change_column :inventory_items, :value, :decimal, :default => BigDecimal.new(0)
    change_column :inventory_items, :ending_value, :decimal, :default => BigDecimal.new(0)
    change_column :inventory_items, :quantity, :integer, :default => 0
    change_column :inventory_items, :unit_starting_value, :decimal, :default => BigDecimal.new(0)
    change_column :inventory_items, :unit_value, :decimal, :default => BigDecimal.new(0)
    change_column :inventory_items, :unit_ending_value, :decimal, :default => BigDecimal.new(0)
    change_column :inventory_items, :total_quantity, :integer, :default => 0
    change_column :inventory_items, :total_sold, :integer, :default => 0
  end
end
