class AddScheduledAtToTimeTimers < ActiveRecord::Migration
  def change
    add_column :time_timers, :scheduled_at, :datetime
  end
end
