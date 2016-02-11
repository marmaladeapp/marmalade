class AddItemClassToOwnershipAncestries < ActiveRecord::Migration
  def change
    add_column :ownership_ancestries, :item_class, :string
    add_index :ownership_ancestries, :item_class
  end
end
