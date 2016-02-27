class AddCounterledgerReferencesToFinancesLedgers < ActiveRecord::Migration
  def change
    add_column :finances_ledgers, :counterledger_id, :integer
    add_index :finances_ledgers, :counterledger_id
  end
end
