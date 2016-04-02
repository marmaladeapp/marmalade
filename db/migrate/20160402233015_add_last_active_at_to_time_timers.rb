class AddLastActiveAtToTimeTimers < ActiveRecord::Migration
  def change
    add_column :time_timers, :last_active_at, :datetime
  end
end
