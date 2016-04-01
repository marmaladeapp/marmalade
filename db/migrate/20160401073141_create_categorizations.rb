class CreateCategorizations < ActiveRecord::Migration
  def change
    create_table :categorizations do |t|
      t.references :category, polymorphic: true, index: true
      t.references :item, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
