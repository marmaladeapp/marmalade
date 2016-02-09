class AddBraintreeSubscriptionIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :braintree_subscription_id, :string
  end
end
