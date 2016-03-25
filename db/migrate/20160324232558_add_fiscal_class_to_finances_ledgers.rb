class AddFiscalClassToFinancesLedgers < ActiveRecord::Migration
  def change
    add_column :finances_ledgers, :fiscal_class, :string
  end
end
