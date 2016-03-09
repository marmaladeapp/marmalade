class AddDefaultToTimeTimers < ActiveRecord::Migration
  def change
    change_column :time_timers, :estimated_time, :integer, :default => 0
    change_column :time_timers, :elapsed_time, :integer, :default => 0
  end
end
