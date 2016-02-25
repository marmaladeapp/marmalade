class AddContextReferencesToFinancesLedgers < ActiveRecord::Migration
  def change
    add_reference :finances_ledgers, :context, polymorphic: true, index: true
  end
end
