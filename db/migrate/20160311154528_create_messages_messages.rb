class CreateMessagesMessages < ActiveRecord::Migration
  def change
    create_table :messages_messages do |t|
      t.string :title
      t.text :content
      t.references :context, polymorphic: true, index: true
      t.references :project, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
