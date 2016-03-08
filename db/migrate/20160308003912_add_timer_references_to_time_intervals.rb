class AddTimerReferencesToTimeIntervals < ActiveRecord::Migration
  def change
    add_reference :time_intervals, :time_timer, index: true, foreign_key: true
  end
end
