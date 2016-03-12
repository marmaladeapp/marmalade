class AddProjectReferencesToCalendarEvents < ActiveRecord::Migration
  def change
    add_reference :calendar_events, :project, index: true, foreign_key: true
  end
end
