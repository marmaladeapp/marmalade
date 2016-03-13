class AddProjectReferencesToFinancesLedgers < ActiveRecord::Migration
  def change
    add_reference :finances_ledgers, :project, index: true, foreign_key: true
  end
end
