class CreateAbstracts < ActiveRecord::Migration
  def change
    create_table :abstracts do |t|
      t.references :context, polymorphic: true, index: true
      t.references :item, polymorphic: true, index: true
      t.references :project, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
