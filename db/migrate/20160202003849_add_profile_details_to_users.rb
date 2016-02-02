class AddProfileDetailsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :bio, :text
    add_column :users, :currency, :string, null: false, default: "USD"
    add_column :users, :time_zone, :string, null: false, default: "UTC"
    add_column :users, :country, :string, null: false, default: "US"
    add_column :users, :language, :string, null: false, default: "en-US"
  end
end
