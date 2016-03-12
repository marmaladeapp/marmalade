class AddProjectReferencesToTimeTimers < ActiveRecord::Migration
  def change
    add_reference :time_timers, :project, index: true, foreign_key: true
  end
end
