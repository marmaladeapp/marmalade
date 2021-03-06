class CreatePaymentMethods < ActiveRecord::Migration
  def change
    create_table :payment_methods do |t|
      t.references :user, index: true, foreign_key: true
      t.string :braintree_payment_method_token

      t.timestamps null: false
    end
  end
end
