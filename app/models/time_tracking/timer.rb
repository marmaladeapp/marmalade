class TimeTracking::Timer < ActiveRecord::Base
  include Abstractable
  default_scope { order(last_active_at: :desc) }

  validates :name, :presence => true

  belongs_to :context, polymorphic: true
  belongs_to :project

  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'
  has_many :time_sheets, :through => :owners, :source => :owner, :source_type => 'TimeTracking::TimeSheet'

  has_many :memberships, :as => :collective, :dependent => :destroy
  has_many :members, :through => :memberships, :source => :member, :source_type => 'User'

  has_many :intervals, :dependent => :destroy, :class_name => 'TimeTracking::Interval', :foreign_key => 'time_timer_id'

  accepts_nested_attributes_for :owners, reject_if: proc { |attributes| attributes['global_owner'].blank? }, allow_destroy: true

  before_create :set_last_active_at_to_now

  def assigned?(user)
    memberships.find_by(:member => user)
  end

  def active?
    intervals.where(:stopped_at => nil).any?
  end

  def active_or_day
    active? ? 'Active' : self.last_active_at.to_date
  end

  private

  def set_last_active_at_to_now
    self.last_active_at = Time.now
  end

end
