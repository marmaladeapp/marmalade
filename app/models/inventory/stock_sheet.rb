class Inventory::StockSheet < ActiveRecord::Base
  belongs_to :item, :class_name => "Inventory::Item", :foreign_key => 'inventory_item_id'
end
