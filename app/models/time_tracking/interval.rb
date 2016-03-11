class TimeTracking::Interval < ActiveRecord::Base
  default_scope { order(stopped_at: :desc) }
  belongs_to :timer, :class_name => "TimeTracking::Timer", :foreign_key => 'time_timer_id', counter_cache: true, touch: true
  belongs_to :user

  def active_or_day
    self.stopped_at ? self.stopped_at.to_date : 'Active'
  end

end
