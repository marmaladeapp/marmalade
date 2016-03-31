class AddTotalSoldToInventoryItems < ActiveRecord::Migration
  def change
    add_column :inventory_items, :total_sold, :integer
  end
end
