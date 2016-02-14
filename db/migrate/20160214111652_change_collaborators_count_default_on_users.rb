class ChangeCollaboratorsCountDefaultOnUsers < ActiveRecord::Migration
  def change
    change_column_default :users, :collaborators_count, 0
  end
end
