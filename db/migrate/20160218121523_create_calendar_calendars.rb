class CreateCalendarCalendars < ActiveRecord::Migration
  def change
    create_table :calendar_calendars do |t|
      t.string :name
      t.text :description
      t.string :slug
      t.references :owner, polymorphic: true, index: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :calendar_calendars, :slug
  end
end
