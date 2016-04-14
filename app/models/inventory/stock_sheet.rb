class Inventory::StockSheet < ActiveRecord::Base
  default_scope { order(created_at: :asc) }
  belongs_to :item, :class_name => "Inventory::Item", :foreign_key => 'inventory_item_id'

  has_one :payment, :class_name => 'Finances::Payment', :foreign_key => 'inventory_stock_sheet_id'

  before_destroy do |stock_sheet|
    if stock_sheet.payment
      stock_sheet.payment.update_attribute(:inventory_stock_sheet_id, nil)
    end
  end
end
