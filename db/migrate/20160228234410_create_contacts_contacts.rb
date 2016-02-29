class CreateContactsContacts < ActiveRecord::Migration
  def change
    create_table :contacts_contacts do |t|
      t.string :name
      t.references :context, polymorphic: true, index: true
      t.references :address_book, index: true
      t.references :item, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
