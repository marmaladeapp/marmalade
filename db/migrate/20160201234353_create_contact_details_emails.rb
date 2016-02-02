class CreateContactDetailsEmails < ActiveRecord::Migration
  def change
    create_table :contact_details_emails do |t|
      t.string :address
      t.references :owner, polymorphic: true, index: true

      t.timestamps null: false
    end
    add_index :contact_details_emails, :address
  end
end
