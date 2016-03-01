class AddCountryCodeToContactDetailsTelephones < ActiveRecord::Migration
  def change
    add_column :contact_details_telephones, :country_code, :string
  end
end
