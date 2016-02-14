class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.string :business_type, null: false, default: "LimitedCompany"
      t.string :country, null: false, default: "US"
      t.string :time_zone, null: false, default: "UTC"
      t.string :currency, null: false, default: "USD"
      t.integer :subscriber_id, null: false

      t.timestamps null: false
    end
    add_index :businesses, :subscriber_id
  end
end
