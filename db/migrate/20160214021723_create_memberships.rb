class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.references :collective, polymorphic: true, index: true
      t.references :member, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
