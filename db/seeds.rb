# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

plan = Plan.find_or_initialize_by(slug: 'free')
plan.name = 'Free'
plan.collaborator_limit = 1
plan.wallet_limit = 2
plan.project_limit = 1
plan.business_limit = 0
plan.household_limit = 0
plan.save!

plan = Plan.find_or_initialize_by(slug: 'early_adopter_light_monthly_gbp')
plan.name = 'Light'
plan.price = BigDecimal.new(5)
plan.currency = 'GBP'
plan.billing_frequency = 1
plan.collaborator_limit = 3
plan.wallet_limit = 4
plan.project_limit = 5
plan.business_limit = 1
plan.household_limit = 1
plan.save!

plan = Plan.find_or_initialize_by(slug: 'early_adopter_light_yearly_gbp')
plan.name = 'Light'
plan.price = BigDecimal.new(45)
plan.currency = 'GBP'
plan.billing_frequency = 12
plan.collaborator_limit = 3
plan.wallet_limit = 4
plan.project_limit = 5
plan.business_limit = 1
plan.household_limit = 1
plan.save!

plan = Plan.find_or_initialize_by(slug: 'early_adopter_pro_monthly_gbp')
plan.name = 'Pro'
plan.price = BigDecimal.new(15)
plan.currency = 'GBP'
plan.billing_frequency = 1
plan.collaborator_limit = 10
plan.wallet_limit = 8
plan.project_limit = 15
plan.business_limit = 4
plan.household_limit = 1
plan.save!

plan = Plan.find_or_initialize_by(slug: 'early_adopter_pro_yearly_gbp')
plan.name = 'Pro'
plan.price = BigDecimal.new(135)
plan.currency = 'GBP'
plan.billing_frequency = 12
plan.collaborator_limit = 10
plan.wallet_limit = 8
plan.project_limit = 15
plan.business_limit = 4
plan.household_limit = 1
plan.save!

plan = Plan.find_or_initialize_by(slug: 'early_adopter_plus_monthly_gbp')
plan.name = 'Plus'
plan.price = BigDecimal.new(25)
plan.currency = 'GBP'
plan.billing_frequency = 1
plan.collaborator_limit = 25
plan.wallet_limit = nil
plan.project_limit = nil
plan.business_limit = nil
plan.household_limit = 1
plan.save!

plan = Plan.find_or_initialize_by(slug: 'early_adopter_plus_yearly_gbp')
plan.name = 'Plus'
plan.price = BigDecimal.new(225)
plan.currency = 'GBP'
plan.billing_frequency = 12
plan.collaborator_limit = 25
plan.wallet_limit = nil
plan.project_limit = nil
plan.business_limit = nil
plan.household_limit = 1
plan.save!

plan = Plan.find_or_initialize_by(slug: 'privileged')
plan.name = 'Privileged'
plan.collaborator_limit = nil
plan.wallet_limit = nil
plan.project_limit = nil
plan.business_limit = nil
plan.household_limit = 1
plan.save!
