class AddProjectReferencesToFinancesPayments < ActiveRecord::Migration
  def change
    add_reference :finances_payments, :project, index: true, foreign_key: true
  end
end
