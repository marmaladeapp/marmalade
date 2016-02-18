class CreateProjectsProjects < ActiveRecord::Migration
  def change
    create_table :projects_projects do |t|
      t.string :name
      t.text :description
      t.string :slug
      t.references :owner, polymorphic: true, index: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :projects_projects, :slug
  end
end
