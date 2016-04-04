class AddPlansViaMigration < ActiveRecord::Migration
  def up
    Plan.create(
      :slug => 'free',
      :name => 'Free',
      :collaborator_limit => 1,
      :wallet_limit => 2,
      :project_limit => 1,
      :business_limit => 0,
      :household_limit => 0
      )

    Plan.create(
      :slug => 'early_adopter_light_monthly_gbp',
      :name => 'Light',
      :price => BigDecimal.new(5),
      :currency => 'GBP',
      :billing_frequency => 1,
      :collaborator_limit => 3,
      :wallet_limit => 4,
      :project_limit => 5,
      :business_limit => 1,
      :household_limit => 1
      )

    Plan.create(
      :slug => 'early_adopter_light_yearly_gbp',
      :name => 'Light',
      :price => BigDecimal.new(45),
      :currency => 'GBP',
      :billing_frequency => 12,
      :collaborator_limit => 3,
      :wallet_limit => 4,
      :project_limit => 5,
      :business_limit => 1,
      :household_limit => 1
      )

    Plan.create(
      :slug => 'early_adopter_pro_monthly_gbp',
      :name => 'Pro',
      :price => BigDecimal.new(15),
      :currency => 'GBP',
      :billing_frequency => 1,
      :collaborator_limit => 10,
      :wallet_limit => 8,
      :project_limit => 15,
      :business_limit => 4,
      :household_limit => 1
      )

    Plan.create(
      :slug => 'early_adopter_pro_yearly_gbp',
      :name => 'Pro',
      :price => BigDecimal.new(135),
      :currency => 'GBP',
      :billing_frequency => 12,
      :collaborator_limit => 10,
      :wallet_limit => 8,
      :project_limit => 15,
      :business_limit => 4,
      :household_limit => 1
      )

    Plan.create(
      :slug => 'early_adopter_plus_monthly_gbp',
      :name => 'Plus',
      :price => BigDecimal.new(25),
      :currency => 'GBP',
      :billing_frequency => 1,
      :collaborator_limit => 25,
      :business_limit => nil,
      :household_limit => 1
      )

    Plan.create(
      :slug => 'early_adopter_plus_yearly_gbp',
      :name => 'Plus',
      :price => BigDecimal.new(225),
      :currency => 'GBP',
      :billing_frequency => 12,
      :collaborator_limit => 25,
      :business_limit => nil,
      :household_limit => 1
      )
  end
  def down
    Plan.destroy_all
  end
end
