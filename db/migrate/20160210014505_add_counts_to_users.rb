class AddCountsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :collaborators_count, :integer, :default => 1
    add_column :users, :organizations_count, :integer, :default => 0
    add_column :users, :wallets_count, :integer, :default => 0
    add_column :users, :projects_count, :integer, :default => 0
  end
end
