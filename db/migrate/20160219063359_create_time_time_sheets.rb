class CreateTimeTimeSheets < ActiveRecord::Migration
  def change
    create_table :time_time_sheets do |t|
      t.string :name
      t.text :description
      t.string :slug
      t.references :owner, polymorphic: true, index: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :time_time_sheets, :slug
  end
end
