class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.text :description
      t.string :country
      t.string :time_zone
      t.string :currency
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
