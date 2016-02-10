class AddLimitsToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :collaborator_limit, :integer
    add_column :plans, :organization_limit, :integer
    add_column :plans, :wallet_limit, :integer
    add_column :plans, :project_limit, :integer
  end
end
