class AddCouterpartyReferencesToFinancesLedgers < ActiveRecord::Migration
  def change
    add_reference :finances_ledgers, :counterparty, polymorphic: true, index: true
  end
end
