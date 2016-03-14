class AddProjectReferencesToTimeIntervals < ActiveRecord::Migration
  def change
    add_reference :time_intervals, :project, index: true, foreign_key: true
  end
end
