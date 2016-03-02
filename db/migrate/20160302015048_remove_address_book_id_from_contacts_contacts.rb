class RemoveAddressBookIdFromContactsContacts < ActiveRecord::Migration
  def change
    remove_column :contacts_contacts, :address_book_id
  end
end
