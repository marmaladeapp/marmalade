class AddRepeatsAndOccuringOnToTimeTimers < ActiveRecord::Migration
  def change
    add_column :time_timers, :repeats, :string
    add_index :time_timers, :repeats
    add_column :time_timers, :occuring_on, :text, array: true
    add_index :time_timers, :occuring_on
  end
end
