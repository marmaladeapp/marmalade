class AddIntervalsCountToTimeTimers < ActiveRecord::Migration
  def change
    add_column :time_timers, :intervals_count, :integer, default: 0
  end
end
