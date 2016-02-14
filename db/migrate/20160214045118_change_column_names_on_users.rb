class ChangeColumnNamesOnUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.rename :collaborators_count, :subscriber_collaborators_count
      t.rename :organizations_count, :subscriber_organizations_count
      t.rename :wallets_count, :subscriber_wallets_count
      t.rename :projects_count, :subscriber_projects_count
    end
  end
end
