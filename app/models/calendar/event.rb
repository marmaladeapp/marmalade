class Calendar::Event < ActiveRecord::Base
  belongs_to :context, polymorphic: true
  belongs_to :item, polymorphic: true

  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'
  has_many :calendars, :through => :owners, :source => :owner, :source_type => 'Calendar::Calendar'

  accepts_nested_attributes_for :owners, reject_if: proc { |attributes| attributes['global_owner'].blank? }
end
