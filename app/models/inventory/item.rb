class Inventory::Item < ActiveRecord::Base
  include Abstractable
  default_scope { order('lower(name)') }
  belongs_to :context, polymorphic: true
  belongs_to :project

  validates :name, :presence => true
  validates :quantity, :presence => true

  has_many :ownerships, :dependent => :destroy, :as => :owner
  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'

  has_many :categories, :as => :item, :dependent => :destroy, :class_name => 'Categorization'
  has_many :containers, :through => :categories, :source => :category, :source_type => 'Inventory::Container'
  
  has_many :stock_sheets, :dependent => :destroy, :class_name => 'Inventory::StockSheet', :foreign_key => 'inventory_item_id'

  belongs_to :item, polymorphic: true

  accepts_nested_attributes_for :owners, reject_if: proc { |attributes| attributes['global_owner'].blank? }
  accepts_nested_attributes_for :categories, reject_if: proc { |attributes| attributes['global_category'].blank? }

  def consumption
    nil
  end
  def consumption=(consumption)
    consumption
  end
  def purchase_value
    nil
  end
  def purchase_value=(purchase_value)
    purchase_value
  end
  def sale_value
    nil
  end
  def sale_value=(sale_value)
    sale_value
  end

  def first_letter
    name[0].capitalize
  end
end
