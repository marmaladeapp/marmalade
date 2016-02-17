class CreateContactsAddressBooks < ActiveRecord::Migration
  def change
    create_table :contacts_address_books do |t|
      t.references :owner, polymorphic: true, index: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
