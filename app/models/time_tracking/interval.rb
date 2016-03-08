class TimeTracking::Interval < ActiveRecord::Base
  default_scope { order(stopped_at: :desc) }
  belongs_to :timer, :class_name => "TimeTracking::Timer", :foreign_key => 'time_timer_id'
  belongs_to :user
end
