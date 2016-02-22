class CreateFinancesLedgers < ActiveRecord::Migration
  def change
    create_table :finances_ledgers do |t|
      t.string :name
      t.text :description
      t.decimal :value
      t.decimal :starting_value
      t.string :currency
      t.datetime :due_in_full_at

      t.timestamps null: false
    end
  end
end
