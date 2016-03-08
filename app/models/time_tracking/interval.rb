class TimeTracking::Interval < ActiveRecord::Base
  belongs_to :timer, :class_name => "TimeTracking::Timer", :foreign_key => 'time_timer_id'
  belongs_to :user
end
