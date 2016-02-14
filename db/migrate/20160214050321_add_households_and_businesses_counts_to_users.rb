class AddHouseholdsAndBusinessesCountsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscriber_households_count, :integer, default: 0
    add_column :users, :subscriber_businesses_count, :integer, default: 0
    remove_column :users, :subscriber_organizations_count
  end
end
