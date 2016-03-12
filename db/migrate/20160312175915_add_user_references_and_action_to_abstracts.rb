class AddUserReferencesAndActionToAbstracts < ActiveRecord::Migration
  def change
    add_reference :abstracts, :user, index: true, foreign_key: true
    add_column :abstracts, :action, :string
  end
end
