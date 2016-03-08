class AddUserReferencesToTimeIntervals < ActiveRecord::Migration
  def change
    add_reference :time_intervals, :user, index: true, foreign_key: true
  end
end
