class CreateOwnershipAncestries < ActiveRecord::Migration
  def change
    create_table :ownership_ancestries do |t|
      t.references :ownership, index: true, foreign_key: true
      t.string :ancestry
      t.integer :ancestry_depth, default: 0

      t.timestamps null: false
    end
    add_index :ownership_ancestries, :ancestry
  end
end
