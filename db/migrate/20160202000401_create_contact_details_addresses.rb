class CreateContactDetailsAddresses < ActiveRecord::Migration
  def change
    create_table :contact_details_addresses do |t|
      t.string :line_1
      t.string :line_2
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.references :owner, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
