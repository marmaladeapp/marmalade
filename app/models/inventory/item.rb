class Inventory::Item < ActiveRecord::Base
  include Abstractable
  default_scope { order('lower(name)') }
  belongs_to :context, polymorphic: true
  belongs_to :project
  
  validates :name, :presence => true

  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'
  has_many :containers, :through => :owners, :source => :owner, :source_type => 'Inventory::Container'

  belongs_to :item, polymorphic: true

  accepts_nested_attributes_for :owners, reject_if: proc { |attributes| attributes['global_owner'].blank? }

  def first_letter
    name[0].capitalize
  end
end
