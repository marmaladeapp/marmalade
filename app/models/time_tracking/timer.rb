class TimeTracking::Timer < ActiveRecord::Base
  default_scope { order(updated_at: :desc) }

  belongs_to :context, polymorphic: true

  has_many :owners, :as => :item, :dependent => :destroy, :class_name => 'Ownership'
  has_many :time_sheets, :through => :owners, :source => :owner, :source_type => 'TimeTracking::TimeSheet'

  has_many :memberships, :as => :collective, :dependent => :destroy
  has_many :members, :through => :memberships, :source => :member, :source_type => 'User'

  has_many :intervals, :dependent => :destroy, :class_name => 'TimeTracking::Interval'

  accepts_nested_attributes_for :owners, reject_if: proc { |attributes| attributes['global_owner'].blank? }

  def assigned?(user)
    memberships.find_by(:member => user)
  end

end
