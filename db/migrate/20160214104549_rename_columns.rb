class RenameColumns < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.rename :subscriber_collaborators_count, :collaborators_count
      t.rename :subscriber_businesses_count, :businesses_count
      t.rename :subscriber_households_count, :households_count
      t.rename :subscriber_wallets_count, :wallets_count
      t.rename :subscriber_projects_count, :projects_count
    end

    remove_column :collaborators, :subscriber_id
    remove_column :businesses, :subscriber_id
    remove_column :households, :subscriber_id

    add_reference :collaborators, :user, index: true, foreign_key: true
    add_reference :businesses, :user, index: true, foreign_key: true
    add_reference :households, :user, index: true, foreign_key: true

  end
end
