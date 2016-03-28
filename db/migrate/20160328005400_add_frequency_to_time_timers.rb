class AddFrequencyToTimeTimers < ActiveRecord::Migration
  def change
    add_column :time_timers, :frequency, :integer
    add_index :time_timers, :frequency
  end
end
