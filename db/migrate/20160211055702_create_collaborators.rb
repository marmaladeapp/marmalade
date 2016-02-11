class CreateCollaborators < ActiveRecord::Migration
  def change
    create_table :collaborators do |t|
      t.references :subscriber, index: true
      t.references :collaborator, index: true

      t.timestamps null: false
    end
  end
end
