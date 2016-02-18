class AddSlugToAddressBooks < ActiveRecord::Migration
  def change
    add_column :contacts_address_books, :slug, :string
    add_index :contacts_address_books, :slug
  end
end
