class Calendar::Event < ActiveRecord::Base
  default_scope { order(starting_at: :asc) }

  belongs_to :context, polymorphic: true
  belongs_to :item, polymorphic: true

  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'
  has_many :calendars, :through => :owners, :source => :owner, :source_type => 'Calendar::Calendar'

  accepts_nested_attributes_for :owners, reject_if: proc { |attributes| attributes['global_owner'].blank? }

  def day
    self.starting_at.to_date
  end

end
