class AddStartingAtAndEndingAtToCalendarEvents < ActiveRecord::Migration
  def change
    add_column :calendar_events, :starting_at, :datetime
    add_column :calendar_events, :ending_at, :datetime
    add_index :calendar_events, :starting_at
    add_index :calendar_events, :ending_at
  end
end
