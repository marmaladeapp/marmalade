class CreateHouseholds < ActiveRecord::Migration
  def change
    create_table :households do |t|
      t.string :name
      t.text :description
      t.string :country, null: false, default: "US"
      t.string :time_zone, null: false, default: "UTC"
      t.string :currency, null: false, default: "USD"
      t.integer :subscriber_id, null: false

      t.timestamps null: false
    end
    add_index :households, :subscriber_id
  end
end
