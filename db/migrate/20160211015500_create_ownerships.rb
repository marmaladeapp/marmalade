class CreateOwnerships < ActiveRecord::Migration
  def change
    create_table :ownerships do |t|
      t.references :owner, polymorphic: true, index: true
      t.references :item, polymorphic: true, index: true
      t.decimal :equity

      t.timestamps null: false
    end
  end
end
