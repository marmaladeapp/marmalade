class CreateInventoryItems < ActiveRecord::Migration
  def change
    create_table :inventory_items do |t|
      t.string :name
      t.text :description
      t.references :context, polymorphic: true, index: true
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
