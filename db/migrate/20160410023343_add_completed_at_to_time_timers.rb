class AddCompletedAtToTimeTimers < ActiveRecord::Migration
  def change
    add_column :time_timers, :completed_at, :datetime
  end
end
