class CreateCalendarEvents < ActiveRecord::Migration
  def change
    create_table :calendar_events do |t|
      t.string :name
      t.text :description
      t.references :context, polymorphic: true, index: true
      t.references :item, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
