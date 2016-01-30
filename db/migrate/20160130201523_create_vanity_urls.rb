class CreateVanityUrls < ActiveRecord::Migration
  def change
    create_table :vanity_urls do |t|
      t.string :slug
      t.string :target
      t.references :owner, polymorphic: true, index: true
    end
    add_index :vanity_urls, :slug, unique: true
  end
end
