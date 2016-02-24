class ChangeNameOfProjectsProjects < ActiveRecord::Migration
  def change
    rename_table :projects_projects, :projects
  end
end
