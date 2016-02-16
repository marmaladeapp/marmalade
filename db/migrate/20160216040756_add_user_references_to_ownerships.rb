class AddUserReferencesToOwnerships < ActiveRecord::Migration
  def change
    add_reference :ownerships, :user, index: true, foreign_key: true
  end
end
