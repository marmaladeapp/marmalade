class AddGroupsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :groups_count, :integer, default: 0
  end
end
