class RemoveItemReferencesFromCalendarEvents < ActiveRecord::Migration
  def change
    remove_column :calendar_events, :item_id
    remove_column :calendar_events, :item_type
  end
end
