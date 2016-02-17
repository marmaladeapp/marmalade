class AddNameAndDescriptionToContactsAddressBooks < ActiveRecord::Migration
  def change
    add_column :contacts_address_books, :name, :string
    add_column :contacts_address_books, :description, :text
  end
end
