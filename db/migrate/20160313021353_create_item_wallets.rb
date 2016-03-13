class CreateItemWallets < ActiveRecord::Migration
  def change
    create_table :item_wallets do |t|
      t.references :item, polymorphic: true, index: true
      t.references :finances_wallet, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
