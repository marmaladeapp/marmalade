class AddBusinessLimitAndHouseholdLimitToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :business_limit, :integer, default: 0 # TODO: We shouldn't have set a default here.
    add_column :plans, :household_limit, :integer, default: 0 # TODO: We shouldn't have set a default here.
    remove_column :plans, :organization_limit
  end
end
