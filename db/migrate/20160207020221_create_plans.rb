class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :slug
      t.string :name
      t.text :description
      t.decimal :price
      t.string :currency
      t.integer :billing_frequency

      t.timestamps null: false
    end
  end
end
