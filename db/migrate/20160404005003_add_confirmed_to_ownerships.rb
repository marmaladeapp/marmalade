class AddConfirmedToOwnerships < ActiveRecord::Migration
  def change
    add_column :ownerships, :confirmed, :boolean
  end
end
