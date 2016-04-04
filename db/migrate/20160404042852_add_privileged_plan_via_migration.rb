class AddPrivilegedPlanViaMigration < ActiveRecord::Migration
  def up
    Plan.create(
      :slug => 'privileged',
      :name => 'Privileged',
      :business_limit => nil,
      :household_limit => 1
      )
  end
  def down
    Plan.find_by(:slug => 'privileged').destroy
  end
end
