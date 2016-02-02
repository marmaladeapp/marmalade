class CreateContactDetailsTelephones < ActiveRecord::Migration
  def change
    create_table :contact_details_telephones do |t|
      t.string :number
      t.references :owner, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
