class AddLastConvertedDatetimeToOwnershipAncestries < ActiveRecord::Migration
  def change
    add_column :ownership_ancestries, :last_converted, :datetime
  end
end
