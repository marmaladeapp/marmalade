class AddUserReferencesToMemberships < ActiveRecord::Migration
  def change
    add_reference :memberships, :user, index: true, foreign_key: true
  end
end
