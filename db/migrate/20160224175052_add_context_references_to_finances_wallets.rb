class AddContextReferencesToFinancesWallets < ActiveRecord::Migration
  def change
    add_reference :finances_wallets, :context, polymorphic: true, index: true
  end
end
