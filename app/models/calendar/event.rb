class Calendar::Event < ActiveRecord::Base
  include Abstractable
  default_scope { order(starting_at: :asc) }

  validates :name, :presence => true
  belongs_to :context, polymorphic: true
  belongs_to :item, polymorphic: true
  belongs_to :project

  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'
  has_many :calendars, :through => :owners, :source => :owner, :source_type => 'Calendar::Calendar'

  has_many :memberships, :as => :collective, :dependent => :destroy
  has_many :members, :through => :memberships, :source => :member, :source_type => 'User'

  validate :range_order

  accepts_nested_attributes_for :owners, reject_if: proc { |attributes| attributes['global_owner'].blank? }, allow_destroy: true

  def day
    self.starting_at.to_date
  end

  def range_order
    if ending_at.present? && starting_at.present? && ending_at < starting_at
      errors.add(:starting_at, "can't be before start date")
    end
  end

  def attending?(user)
    memberships.find_by(:member => user)
  end

end
