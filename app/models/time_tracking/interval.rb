class TimeTracking::Interval < ActiveRecord::Base
  include Abstractable
  default_scope { order(stopped_at: :desc) }
  belongs_to :timer, :class_name => "TimeTracking::Timer", :foreign_key => 'time_timer_id', counter_cache: true, touch: :last_active_at
  belongs_to :user
  belongs_to :project

  def active_or_day
    self.stopped_at ? self.stopped_at.to_date : 'Active'
  end

end
