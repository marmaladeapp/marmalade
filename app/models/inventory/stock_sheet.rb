class Inventory::StockSheet < ActiveRecord::Base
  default_scope { order(created_at: :asc) }
  belongs_to :item, :class_name => "Inventory::Item", :foreign_key => 'inventory_item_id'
end
